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
        let senderAccountId: String
        let senderBalanceId: String
        let asset: String
        let amount: UInt64
        let salt: UInt64
        let minTimeBound: UInt64
        let maxTimeBound: UInt64
        let hintWrapped: Data
        let signature: Data
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
        case failedToFetchDecodeRedeemRequest
        case failedToDecodeSenderAccountId
        case failedToFetchSenderAccount
        case failedToDecodeRedeemAsset
        case failedToFindSenderBalance
        case other(Error)
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
