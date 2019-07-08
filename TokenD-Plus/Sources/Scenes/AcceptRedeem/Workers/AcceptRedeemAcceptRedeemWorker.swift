import Foundation

public enum AcceptRedeemAcceptRedeemResult {
    case failure(AcceptRedeem.Model.AcceptRedeemError)
    case success(AcceptRedeem.Model.RedeemModel)
}
public protocol AcceptRedeemAcceptRedeemWorkerProtocol {
    func acceptRedeem(
        completion: @escaping (AcceptRedeemAcceptRedeemResult) -> Void
        )
}

extension AcceptRedeem {
    public typealias AcceptRedeemWorkerProtocol = AcceptRedeemAcceptRedeemWorkerProtocol
    
    public class AcceptRedeemWorker: AcceptRedeemWorkerProtocol {
        
        // MARK: - Private properties
        
        private let redeemRequest: String
        
        // MARK: -
        
        public init(redeemRequest: String) {
            self.redeemRequest = redeemRequest
        }
        
        // MARK: - AcceptRedeemWorkerProtocol
        
        public func acceptRedeem(
            completion: @escaping (AcceptRedeemAcceptRedeemResult) -> Void
            ) {
            
            
            
        }
    }
}

