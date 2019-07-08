import UIKit

public enum AcceptRedeem {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension AcceptRedeem.Model {
    
    public struct RedeemModel {
        let senderBalanceId: String
        let asset: String
        let amount: Decimal
        let recipientNickname: String
        let recipientAccountId: String
        let senderFee: FeeModel
        let recipientFee: FeeModel
        let description: String
        let reference: String
    }
    
    public struct FeeModel {
        let asset: String
        let fixed: Decimal
        let percent: Decimal
    }
    
    public enum LoadingStatus {
        case loaded
        case loading
    }
    
    public enum AcceptRedeemError: Error {
        
    }
}

// MARK: - Events

extension AcceptRedeem.Event {
    public typealias Model = AcceptRedeem.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
    }
    
    public enum LoadingStatusDidChange {
        public typealias Response = Model.LoadingStatus
        public typealias ViewModel = Model.LoadingStatus
    }
    
    public enum AcceptRedeemRequestHandled {
        public enum Response {
            case success(Model.RedeemModel)
            case failure(Model.AcceptRedeemError)
        }
        
        public enum ViewModel {
            case success(Model.RedeemModel)
            case failure(String)
        }
    }
}
