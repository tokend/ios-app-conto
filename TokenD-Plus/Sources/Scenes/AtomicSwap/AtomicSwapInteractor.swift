import Foundation
import RxCocoa
import RxSwift

public protocol AtomicSwapBusinessLogic {
    typealias Event = AtomicSwap.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onRefreshInitiated(request: Event.RefreshInitiated.Request)
    func onBuyAction(request: Event.BuyAction.Request)
}

extension AtomicSwap {
    public typealias BusinessLogic = AtomicSwapBusinessLogic
    
    @objc(AtomicSwapInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = AtomicSwap.Event
        public typealias Model = AtomicSwap.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let asksFetcher: AsksFetcherProtocol
        private var sceneModel: Model.SceneModel
        
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            asksFetcher: AsksFetcherProtocol,
            sceneModel: Model.SceneModel
            ) {
            
            self.presenter = presenter
            self.asksFetcher = asksFetcher
            self.sceneModel = sceneModel
        }
        
        // MARK: - Private
        
        private func observeAsks() {
            self.asksFetcher
                .observeAsks()
                .subscribe(onNext: { [weak self] (asks) in
                    self?.sceneModel.asks = asks
                    self?.updateScene()
                })
            .disposed(by: self.disposeBag)
        }
        
        private func observeLoadingStatus() {
            self.loadingStatus
                .subscribe(onNext: { [weak self] (status) in
                    self?.presenter.presentLoadingStatusDidChange(response: status)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func updateScene() {
            guard !self.sceneModel.asks.isEmpty else {
                self.presenter.presentSceneDidUpdate(response: .empty)
                return
            }
            
            var cells: [Model.Cell] = []
            let headerCell = self.getHeaderCell()
            cells.append(headerCell)
            
            self.sceneModel.asks.forEach { (ask) in
                let askCell = Model.Cell.ask(ask)
                cells.append(askCell)
            }
            
            let response = Event.SceneDidUpdate.Response.cells(cells: cells)
            self.presenter.presentSceneDidUpdate(response: response)
        }
        
        private func getHeaderCell() -> Model.Cell {
            let header = Model.Header(asset: self.sceneModel.asset)
            return .header(header)
        }
    }
}

extension AtomicSwap.Interactor: AtomicSwap.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.observeLoadingStatus()
        self.observeAsks()
    }
    
    public func onRefreshInitiated(request: Event.RefreshInitiated.Request) {
        self.asksFetcher
    }
    
    public func onBuyAction(request: Event.BuyAction.Request) {
        guard let ask = self.sceneModel.asks.first(where: { (sceneAsk) -> Bool in
            return sceneAsk.id == request.id
        }) else {
            return
        }
        
        let response = Event.BuyAction.Response(ask: ask)
        self.presenter.presentBuyAction(response: response)
    }
}
