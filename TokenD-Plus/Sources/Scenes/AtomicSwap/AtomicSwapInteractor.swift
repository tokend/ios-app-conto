import Foundation
import RxCocoa
import RxSwift

public protocol AtomicSwapBusinessLogic {
    typealias Event = AtomicSwap.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onRefreshInitiated(request: Event.RefreshInitiated.Request)
}

extension AtomicSwap {
    public typealias BusinessLogic = AtomicSwapBusinessLogic
    
    @objc(AtomicSwapInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = AtomicSwap.Event
        public typealias Model = AtomicSwap.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(presenter: PresentationLogic) {
            self.presenter = presenter
        }
        
        // MARK: - Private
        
        private func observeLoadingStatus() {
            self.loadingStatus
                .subscribe(onNext: { [weak self] (status) in
                    self?.presenter.presentLoadingStatusDidChange(response: status)
                })
                .disposed(by: self.disposeBag)
        }
    }
}

extension AtomicSwap.Interactor: AtomicSwap.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.observeLoadingStatus()
        
        let ask = Model.Ask(
            available: Model.Amount.init(asset: "SHR", value: 28),
            prices: [
                Model.Amount(asset: "UAH", value: 30),
                Model.Amount(asset: "USD", value: 1.4),
                Model.Amount(asset: "ksabdaiucdunU", value: 1.4),
                Model.Amount(asset: "TYR", value: 1.4),
                Model.Amount(asset: "TYR", value: 1.4),
                Model.Amount(asset: "TYR", value: 1.4),
                Model.Amount(asset: "TYR", value: 1.4),
                Model.Amount(asset: "TYR", value: 1.4)
            ]
        )
        let headerCell = Model.Cell.header(Model.Header(asset: "SHR"))
        let askCell = Model.Cell.ask(ask)
        let response = Event.SceneDidUpdate.Response.cells(cells: [headerCell, askCell])
        self.presenter.presentSceneDidUpdate(response: response)
    }
    
    public func onRefreshInitiated(request: Event.RefreshInitiated.Request) {
        
    }
}
