import Foundation
import TokenDSDK
import RxSwift
import RxCocoa

public protocol AtomicSwapAsksFetcherProtocol {
    func observeAsks() -> Observable<[AtomicSwap.Model.Ask]>
    func observeErrors() -> Observable<Swift.Error>
    func observeLoadingStatus() -> Observable<AtomicSwap.Model.LoadingStatus>
}

extension AtomicSwap {
    public typealias AsksFetcherProtocol = AtomicSwapAsksFetcherProtocol
    
    public class AsksFetcher {
        
        // MARK: - Private properties
        
        private let asksRepo: AtomicSwapAsksRepo
        
        private let asks: BehaviorRelay<[Model.Ask]> = BehaviorRelay(value: [])
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let errors: PublishRelay<Swift.Error> = PublishRelay()
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        init(asksRepo: AtomicSwapAsksRepo) {
            self.asksRepo = asksRepo
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
            let asks = resources.compactMap { (resource) -> Model.Ask? in
                guard
                    let id = resource.id,
                    let baseAsset = resource.baseAsset?.id else {
                        return nil
                }
                let available = Model.BaseAmount(
                    asset: baseAsset,
                    value: resource.availableAmount
                )
                guard let quoteAssets = resource.quoteAssets else {
                    return nil
                }
                
                let prices = quoteAssets.compactMap({ (assetResource) -> Model.QuoteAmount? in
                    guard let asset = assetResource.id else {
                        return nil
                    }
                    return Model.QuoteAmount(
                        asset: asset,
                        value: assetResource.price
                    )
                })
                
                return Model.Ask(
                    id: id,
                    available: available,
                    prices: prices
                )
            }
            self.asks.accept(asks)
        }
    }
}

extension AtomicSwap.AsksFetcher: AtomicSwap.AsksFetcherProtocol {
    
    public func observeAsks() -> Observable<[AtomicSwap.Model.Ask]> {
        self.asksRepo.reloadAsks()
        self.observeRepoAsks()
        return self.asks.asObservable()
    }
    
    public func observeErrors() -> Observable<Error> {
        return self.errors.asObservable()
    }
    
    public func observeLoadingStatus() -> Observable<AtomicSwap.Model.LoadingStatus> {
        self.observeRepoLoadingStatus()
        return self.loadingStatus.asObservable()
    }
}

extension AtomicSwapAsksRepo.LoadingStatus {
    var status: AtomicSwap.Model.LoadingStatus {
        switch self {
        case .loaded :
            return .loaded
            
        case .loading:
            return .loading
        }
    }
}
