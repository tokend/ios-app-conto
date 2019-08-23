import Foundation
import TokenDSDK
import RxCocoa
import RxSwift

protocol BalanceHeaderBalanceFetcherProtocol {
    func observeBalance() -> Observable<BalanceHeader.Model.Balance?>
    func reloadBalance()
}

extension BalanceHeader {
    typealias BalanceFetcherProtocol = BalanceHeaderBalanceFetcherProtocol
    
    class BalancesFetcher {
        
        // MARK: - Private properties
        
        private let balancesRepo: BalancesRepo
        private let assetsRepo: AssetsRepo
        
        private let balance: BehaviorRelay<BalanceHeader.Model.Balance?> = BehaviorRelay(value: nil)
        private let imageUtility: ImagesUtility
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        private let balanceId: String
        private let rateAsset: String = "USD"
        
        // MARK: -
        
        init(
            balancesRepo: BalancesRepo,
            assetsRepo: AssetsRepo,
            imageUtility: ImagesUtility,
            balanceId: String
            ) {
            
            self.balancesRepo = balancesRepo
            self.assetsRepo = assetsRepo
            self.imageUtility = imageUtility
            self.balanceId = balanceId
        }
        
        // MARK: - Private
        
        private func observeBalancesRepo() {
            self.balancesRepo
                .observeConvertedBalancesStates()
                .subscribe(onNext: { [weak self] (states) in
                    self?.updateBalance(states: states)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func updateBalance(states: [ConvertedBalanceStateResource]) {
            guard
                let state = states.first(where: { (state) -> Bool in
                    return state.balance?.id == self.balanceId
                }),
                let balanceResource = state.balance,
                let balance = state.initialAmounts,
                let asset = balanceResource.asset,
                let assetName = asset.name else {
                    return
            }
            
            var iconUrl: URL?
            if let key = asset.customDetails?.logo?.key {
                let imageKey = ImagesUtility.ImageKey.key(key)
                iconUrl = self.imageUtility.getImageURL(imageKey)
            }
            
            let amount = BalanceHeader.Model.Amount(
                value: balance.available,
                assetName: assetName
            )
            
            let updatedBalance = Model.Balance(
                balance: amount,
                iconUrl: iconUrl
            )
            self.balance.accept(updatedBalance)
        }
    }
}

extension BalanceHeader.BalancesFetcher: BalanceHeader.BalanceFetcherProtocol {
    
    public func observeBalance() -> Observable<BalanceHeader.Model.Balance?> {
        self.observeBalancesRepo()
        return self.balance.asObservable()
    }
    
    public func reloadBalance() {
        self.balancesRepo.reloadConvertedBalancesStates()
    }
}
