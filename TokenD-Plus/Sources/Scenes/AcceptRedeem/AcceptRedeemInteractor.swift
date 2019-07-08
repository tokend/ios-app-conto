import Foundation
import RxSwift
import RxCocoa

public protocol AcceptRedeemBusinessLogic {
    typealias Event = AcceptRedeem.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
}

extension AcceptRedeem {
    public typealias BusinessLogic = AcceptRedeemBusinessLogic
    
    @objc(AcceptRedeemInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = AcceptRedeem.Event
        public typealias Model = AcceptRedeem.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let acceptRedeemWorker: AcceptRedeemWorkerProtocol
        
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            acceptRedeemWorker: AcceptRedeemWorkerProtocol
            ) {
            
            self.presenter = presenter
            self.acceptRedeemWorker = acceptRedeemWorker
        }
        
        // MARK: - Private
        
        private func observeLoadingStatus() {
            self.loadingStatus
                .subscribe(onNext: { [weak self] (status) in
                    self?.presenter.presentLoadingStatusDidChange(response: status)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func handleAcceptRedeemRequest() {
            self.loadingStatus.accept(.loading)
            self.acceptRedeemWorker.acceptRedeem(
                completion: { [weak self] (result) in
                    self?.loadingStatus.accept(.loaded)
                    let response: Event.AcceptRedeemRequestHandled.Response
                    switch result {
                        
                    case .failure(let error):
                        response = .failure(error)
                        
                    case .success(let redeemModel):
                        response = .success(redeemModel)
                    }
                    self?.presenter.presentAcceptRedeemRequestHandled(response: response)
                }
            )
        }
    }
}

extension AcceptRedeem.Interactor: AcceptRedeem.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.observeLoadingStatus()
        self.handleAcceptRedeemRequest()
    }
}
