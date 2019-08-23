import Foundation
import TokenDWallet
import RxSwift

enum SendPaymentAmountBalanceDetailsLoaderLoadingStatus {
    case loading
    case loaded
}
extension SendPaymentAmountBalanceDetailsLoaderLoadingStatus {
    var responseValue: SendPaymentAmount.Event.LoadBalances.Response {
        switch self {
            
        case .loaded:
            return .loaded
            
        case .loading:
            return .loading
        }
    }
}

protocol SendPaymentsAmountBalanceDetailsLoaderProtocol {
    func observeBalanceDetails() -> Observable<[SendPaymentAmount.Model.BalanceDetails]>
    func observeLoadingStatus() -> Observable<SendPaymentAmountBalanceDetailsLoaderLoadingStatus>
    func observeErrors() -> Observable<Swift.Error>
    func loadBalanceDetails()
}

extension SendPaymentAmount {
    typealias BalanceDetailsLoader = SendPaymentsAmountBalanceDetailsLoaderProtocol
}

extension SendPaymentAmount {
    class BalanceDetailsLoaderWorker {
        
        // MARK: - Private properties
        
        private let balancesRepo: BalancesRepo
        private let assetsRepo: AssetsRepo
        private let operation: SendPaymentAmount.Model.Operation
        private let ownerAccountId: String
        
        // MARK: -
        
        init(
            balancesRepo: BalancesRepo,
            assetsRepo: AssetsRepo,
            operation: SendPaymentAmount.Model.Operation,
            ownerAccountId: String
            ) {
            
            self.balancesRepo = balancesRepo
            self.assetsRepo = assetsRepo
            self.operation = operation
            self.ownerAccountId = ownerAccountId
        }
        
        // MARK: - Private
        
        private func filterWithdrawable(
            balances: [SendPaymentAmount.Model.BalanceDetails]
            ) -> [SendPaymentAmount.Model.BalanceDetails] {
            
            return balances.filter { [weak self] (balance) -> Bool in
                if let ownerAccountId = self?.ownerAccountId,
                    let asset = self?.assetsRepo.assetsValue.first(where: { (asset) -> Bool in
                        return asset.code == balance.assetCode &&
                            asset.owner == ownerAccountId
                    }) {
                    return Int32(asset.policy) & AssetPolicy.withdrawable.rawValue == AssetPolicy.withdrawable.rawValue
                }
                return false
            }
        }
        
        private func getAssetName(code: String) -> String {
            let asset = self.assetsRepo.assetsValue.first(where: { (asset) -> Bool in
                return asset.code == code
            })
            return asset?.defaultDetails?.name ?? code
        }
    }
}

// MARK: - BalanceDetailsLoader

extension SendPaymentAmount.BalanceDetailsLoaderWorker: SendPaymentAmount.BalanceDetailsLoader {
    func observeBalanceDetails() -> Observable<[SendPaymentAmount.Model.BalanceDetails]> {
        typealias BalanceDetails = SendPaymentAmount.Model.BalanceDetails
        
        return self.balancesRepo.observeConvertedBalancesStates().map { (balanceDetails) -> [BalanceDetails] in
            let balances = balanceDetails.compactMap({ (balanceState) -> BalanceDetails? in
                switch balanceState {
                    
                case .created(let balance):
                    let assetName = self.getAssetName(code: balance.asset)
                    let balanceModel = BalanceDetails(
                        assetCode: balance.asset,
                        assetName: assetName,
                        balance: balance.balance,
                        balanceId: balance.balanceId
                    )
                    return balanceModel
                    
                case .creating:
                    return nil
                }
            })
            
            switch self.operation {
                
            case .handleSend,
                 .handleRedeem:
                
                return balances.filter({ [weak self] (balance) -> Bool in
                    if let ownerAccountId = self?.ownerAccountId,
                        let asset = self?.assetsRepo.assetsValue.first(where: { (asset) -> Bool in
                            return asset.code == balance.assetCode &&
                                asset.owner == ownerAccountId
                        }) {
                        
                        return balance.balance > 0 &&
                            asset.owner == ownerAccountId
                    } else {
                        return false
                    }
                })
                
            case .handleWithdraw:
                return self.filterWithdrawable(balances: balances)
                
            case .handleAtomicSwap:
                return balances
            }
        }
    }
    
    func observeLoadingStatus() -> Observable<SendPaymentAmountBalanceDetailsLoaderLoadingStatus> {
        return self.balancesRepo
            .observeLoadingStatus()
            .map { (status) -> SendPaymentAmountBalanceDetailsLoaderLoadingStatus in
                return status.status
        }
    }
    
    func observeErrors() -> Observable<Swift.Error> {
        return self.balancesRepo.observeErrorStatus()
    }
    
    func loadBalanceDetails() {
        self.balancesRepo.reloadBalancesDetails()
    }
}

private extension BalancesRepo.LoadingStatus {
    var status: SendPaymentAmountBalanceDetailsLoaderLoadingStatus {
        switch self {
        case .loading:
            return .loading
        case .loaded:
            return .loaded
        }
    }
}
