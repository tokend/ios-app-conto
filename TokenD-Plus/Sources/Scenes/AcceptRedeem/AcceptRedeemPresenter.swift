import Foundation

public protocol AcceptRedeemPresentationLogic {
    typealias Event = AcceptRedeem.Event
    
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
    func presentAcceptRedeemRequestHandled(response: Event.AcceptRedeemRequestHandled.Response)
}

extension AcceptRedeem {
    public typealias PresentationLogic = AcceptRedeemPresentationLogic
    
    @objc(AcceptRedeemPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = AcceptRedeem.Event
        public typealias Model = AcceptRedeem.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension AcceptRedeem.Presenter: AcceptRedeem.PresentationLogic {
    
    public func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayLoadingStatusDidChange(viewModel: viewModel)
        }
    }
    
    public func presentAcceptRedeemRequestHandled(response: Event.AcceptRedeemRequestHandled.Response) {
        let viewModel: Event.AcceptRedeemRequestHandled.ViewModel
        
        switch response {
            
        case .failure(let error):
            viewModel = .failure(error.localizedDescription)
            
        case .success(let redeemModel):
            viewModel = .success(redeemModel)
        }
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayAcceptRedeemRequestHandled(viewModel: viewModel)
        }
    }
}
