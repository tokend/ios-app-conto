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

extension AcceptRedeem.Model.AcceptRedeemError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
            
        case .failedToFetchDecodeRedeemRequest:
            return Localized(.invalid_redeem_request)
            
        case .failedToDecodeSenderAccountId:
            return Localized(.invalid_sender_account_id)
            
        case .failedToFetchSenderAccount:
            return Localized(.failed_to_fetch_sender_account)
            
        case .failedToDecodeRedeemAsset:
            return Localized(.invalid_redeem_asset)
        
        case .failedToFindSenderBalance:
            return Localized(.failed_to_fetch_sender_balance)
            
        case .other(let error):
            return error.localizedDescription
        }
    }
}
