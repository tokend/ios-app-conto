import Foundation
import TokenDSDK
import RxCocoa
import RxSwift

protocol BalanceListBalanceFetcherProtocol {
    func observeBalances() -> Observable<[BalancesList.Model.Balance]>
    func observeLoadingStatus() -> Observable<BalancesList.Model.LoadingStatus>
    func observeErrors() -> Observable<Swift.Error>
    func reloadBalances()
    
    var isLoading: Bool { get }
}

extension BalancesList {
    typealias BalancesFetcherProtocol = BalanceListBalanceFetcherProtocol
    
    class BalancesFetcher {
        
        // MARK: - Private properties
        
        private let accountApiV3: AccountsApiV3
        private let ownerAccountId: String
        private let conversionAsset: String
        private let originalAccountId: String
        
        private let imageUtility: ImagesUtility
        private let balancesRelay: BehaviorRelay<[Model.Balance]> = BehaviorRelay(value: [])
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let error: PublishRelay<Swift.Error> = PublishRelay()
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        init(
            accountApiV3: AccountsApiV3,
            ownerAccountId: String,
            originalAccountId: String,
            conversionAsset: String,
            imageUtility: ImagesUtility
            ) {
            
            self.accountApiV3 = accountApiV3
            self.ownerAccountId = ownerAccountId
            self.originalAccountId = originalAccountId
            self.conversionAsset = conversionAsset
            self.imageUtility = imageUtility
        }
        
        // MARK: - Private
        
        private func loadBalances() {
            self.loadingStatus.accept(.loading)
            self.accountApiV3.requestConvertedBalances(
                accountId: self.originalAccountId,
                convertationAsset: self.conversionAsset,
                include: ["balance", "balance.asset", "states"],
                completion: { [weak self] (result) in
                    self?.loadingStatus.accept(.loaded)
                    switch result {
                        
                    case .failure(let error):
                        self?.error.accept(error)
                        
                    case .success(let document):
                        guard let balances = document.data else {
                            return
                        }
                        self?.handleConvertedBalances(convertedBalances: balances)
                    }
                }
            )
        }
        
        private func handleConvertedBalances(convertedBalances: ConvertedBalancesCollectionResource) {
            guard let states = convertedBalances.states else {
                return
            }
            let balances = states
                .filter({ (state) -> Bool in
                    return state.balance?.asset?.owner?.id == self.ownerAccountId
                })
                .compactMap { (state) -> Model.Balance? in
                guard
                    let asset = state.balance?.asset,
                    let code = asset.id,
                    let assetName = asset.name,
                    let balance = state.initialAmounts?.available,
                    let balanceId = state.balance?.id,
                    let convertedBalance = state.convertedAmounts?.available else {
                        return nil
                }
                
                var iconUrl: URL?
                if let key = asset.customDetails?.logo?.key {
                    let imageKey = ImagesUtility.ImageKey.key(key)
                    iconUrl = self.imageUtility.getImageURL(imageKey)
                }
                
                return Model.Balance(
                    code: code,
                    assetName: assetName,
                    iconUrl: iconUrl,
                    balance: balance,
                    balanceId: balanceId,
                    convertedBalance: convertedBalance,
                    cellIdentifier: .balances
                )}
                .filter({ (balance) -> Bool in
                    return balance.balance > 0
                })
                .sorted(by: { (left, right) -> Bool in
                    return left.balance > right.balance
                })
            self.balancesRelay.accept(balances)
        }
    }
}

extension BalancesList.BalancesFetcher: BalancesList.BalancesFetcherProtocol {
    
    public var isLoading: Bool {
        get {
            return self.loadingStatus.value == .loading
        }
    }
    
    func observeBalances() -> Observable<[BalancesList.Model.Balance]> {
        self.loadBalances()
        return self.balancesRelay.asObservable()
    }
    
    func observeLoadingStatus() -> Observable<BalancesList.Model.LoadingStatus> {
        return self.loadingStatus.asObservable()
    }
    
    func observeErrors() -> Observable<Swift.Error> {
        return self.error.asObservable()
    }
    
    func reloadBalances() {
        self.loadBalances()
    }
}
