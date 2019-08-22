import Foundation
import TokenDSDK
import RxSwift
import RxCocoa

public protocol BalancesListAtomicSwapAsksFetcherProtocol {
    func observeAsks() -> Observable<[BalancesList.Model.AskModel]>
    func observeErrors() -> Observable<Swift.Error>
    func observeLoadingStatus() -> Observable<BalancesList.Model.LoadingStatus>
    func reloadAsks()
    
    var isLoading: Bool { get }
}

extension BalancesList {
    public typealias AsksFetcherProtocol = BalancesListAtomicSwapAsksFetcherProtocol
    
    public class AsksFetcher {
        
        // MARK: - Private properties
        
        private let asksRepo: AtomicSwapAsksRepo
        private let apiConfigurationModel: APIConfigurationModel
        
        private let asks: BehaviorRelay<[Model.AskModel]> = BehaviorRelay(value: [])
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let errors: PublishRelay<Swift.Error> = PublishRelay()
        
        private let priceAsset: String = "UAH"
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        init(
            asksRepo: AtomicSwapAsksRepo,
            apiConfigurationModel: APIConfigurationModel
            ) {
            
            self.asksRepo = asksRepo
            self.apiConfigurationModel = apiConfigurationModel
        }
        
        // MARK: - Private
        
        private func observeRepoAsks() {
            self.asksRepo
                .observeAsks()
                .subscribe(onNext: { [weak self] (askResources) in
                    self?.handleAskResources(resources: askResources)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func observeRepoLoadingStatus() {
            self.asksRepo
                .observeLoadingStatus()
                .subscribe(onNext: { (status) in
                    self.loadingStatus.accept(status.status)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func handleAskResources(resources: [AtomicSwapAskResource]) {
            let asks = resources.compactMap { (resource) -> Model.AskModel? in
                guard
                    let id = resource.id,
                    let baseAsset = resource.baseAsset?.id,
                    let baseAssetName = resource.baseAsset?.name,
                    let quoteAssets = resource.quoteAssets else {
                        return nil
                }
                
                let available = Model.BaseAmount(
                    assetCode: baseAsset,
                    assetName: baseAssetName,
                    value: resource.availableAmount
                )
                let prices = quoteAssets.compactMap({ (assetResource) -> Model.QuoteAmount? in
                    guard let assetCode = assetResource.id else {
                        return nil
                    }
                    return Model.QuoteAmount(
                        assetCode: assetCode,
                        assetName: assetResource.quoteAsset,
                        value: assetResource.price
                    )
                }).filter({ (price) -> Bool in
                    return price.assetName == self.priceAsset
                })
                
                let ask = Model.Ask(
                    id: id,
                    available: available,
                    prices: prices
                )
                
                var imageUrl: URL?
                if let key = resource.baseAsset?.customDetails?.logo?.key,
                    !key.isEmpty {
                    imageUrl = URL(string: self.apiConfigurationModel.storageEndpoint/key)
                }
                return Model.AskModel(
                    ask: ask,
                    imageUrl: imageUrl
                )
            }
            self.asks.accept(asks)
        }
    }
}

extension BalancesList.AsksFetcher: BalancesList.AsksFetcherProtocol {
    
    public var isLoading: Bool {
        get {
            return self.loadingStatus.value == .loading
        }
    }
    
    public func observeAsks() -> Observable<[BalancesList.Model.AskModel]> {
        self.observeRepoAsks()
        self.asksRepo.reloadAsks()
        return self.asks.asObservable()
    }
    
    public func observeErrors() -> Observable<Error> {
        return self.errors.asObservable()
    }
    
    public func observeLoadingStatus() -> Observable<BalancesList.Model.LoadingStatus> {
        self.observeRepoLoadingStatus()
        return self.loadingStatus.asObservable()
    }
    
    public func reloadAsks() {
        self.asksRepo.reloadAsks()
    }
}

private extension AtomicSwapAsksRepo.LoadingStatus {
    var status: BalancesList.Model.LoadingStatus {
        switch self {
        case .loaded :
            return .loaded
            
        case .loading:
            return .loading
        }
    }
}
