import Foundation
import TokenDSDK
import DLJSONAPI
import RxSwift
import RxCocoa

public class AtomicSwapAsksRepo {
    
    // MARK: - Private properties
    
    private let quoteAssets: String = "quote_assets"
    
    private let atomicSwapApi: AtomicSwapApiV3
    private let baseAsset: String
    
    private let pagination: RequestPagination = {
        let strategy = IndexedPaginationStrategy(index: nil, limit: 10, order: .descending)
        return RequestPagination(.strategy(strategy))
    }()
    private var prevRequest: JSONAPI.RequestModel?
    private var prevLinks: Links?
    private var isLoadingMore: Bool = false
    
    private let asks: BehaviorRelay<[AtomicSwapAskResource]> = BehaviorRelay(value: [])
    private let loadingStatus: BehaviorRelay<LoadingStatus> = BehaviorRelay(value: .loaded)
    private let errorStatus: PublishRelay<Swift.Error> = PublishRelay()
    
    // MARK: -
    
    init(
        atomicSwapApi: AtomicSwapApiV3,
        baseAsset: String
        ) {
        
        self.atomicSwapApi = atomicSwapApi
        self.baseAsset = baseAsset
    }
    
    // MARK: - Public
    
    func observeAsks() -> Observable<[AtomicSwapAskResource]> {
        self.loadAsks()
        return self.asks.asObservable()
    }
    
    func reloadAsks() {
        self.loadAsks()
    }
    
    func observeLoadingStatus() -> Observable<LoadingStatus> {
        return self.loadingStatus.asObservable()
    }
    
    func observeErrorStatus() -> Observable<Swift.Error> {
        return self.errorStatus.asObservable()
    }
    
    func loadMoreAsks() {
        guard let prevRequest = self.prevRequest,
            let links = self.prevLinks,
            links.next != nil,
            !self.isLoadingMore else {
                return
        }
        
        self.isLoadingMore = true
        self.loadingStatus.accept(.loading)
        self.atomicSwapApi.loadPageForLinks(
            AtomicSwapAskResource.self,
            links: links,
            page: .next,
            previousRequest: prevRequest,
            shouldSign: true,
            onRequestBuilt: { [weak self] (prevRequest) in
                self?.prevRequest = prevRequest
            },
            completion: { [weak self] (result) in
                self?.isLoadingMore = false
                self?.loadingStatus.accept(.loaded)
                
                switch result {
                    
                case .failure(let error):
                    self?.errorStatus.accept(error)
                    
                case .success(let document):
                    if let asks = document.data {
                        self?.prevLinks = document.links
                        var currentAsks = self?.asks.value ?? []
                        currentAsks.append(contentsOf: asks)
                        self?.asks.accept(currentAsks)
                    }
                }
        })
    }
    
    // MARK: - Private
    
    private func loadAsks() {
        let filter = AtomicSwapFiltersV3.with(.baseAsset(self.baseAsset))
        self.loadingStatus.accept(.loading)
        _ = self.atomicSwapApi.requestAtomicSwapAsks(
            filters: filter,
            include: [self.quoteAssets],
            pagination: self.pagination,
            onRequestBuilt: { [weak self] (request) in
                self?.prevRequest = request
            },
            completion: { [weak self] (result) in
                self?.loadingStatus.accept(.loaded)
                switch result {
                    
                case .failure(let error):
                    self?.errorStatus.accept(error)
                    
                case .success(let document):
                    guard let asks = document.data else {
                        return
                    }
                    self?.prevLinks = document.links
                    self?.asks.accept(asks)
                }
        })
    }
}

extension AtomicSwapAsksRepo {
    
    public enum LoadingStatus {
        case loaded
        case loading
    }
}
