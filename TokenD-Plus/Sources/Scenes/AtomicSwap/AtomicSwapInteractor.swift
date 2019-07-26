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
    }
    
    public func onRefreshInitiated(request: Event.RefreshInitiated.Request) {
        
    }
}
