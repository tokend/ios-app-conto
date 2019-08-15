import Foundation
import TokenDSDK

public enum KYCVerificationCheckerResult {
    case verified
}
public protocol KYCVerificationCheckerProtocol {
    func startToCheck(completion: @escaping(KYCVerificationCheckerResult) -> Void)
}

extension KYC {
    public typealias VerificationCheckerProtocol = KYCVerificationCheckerProtocol
    
    public class VerificationChecker {
        
        // MARK: - Private
        
        private let accountsApi: AccountsApiV3
        private let accountId: String
        
        private let dispatchQueue: DispatchQueue = DispatchQueue(label: "queue")
        
        // MARK: -
        
        init(
            accountsApi: AccountsApiV3,
            accountId: String
            ) {
            
            self.accountsApi = accountsApi
            self.accountId = accountId
        }
        
        // MARK: - Private
        
        private func fetchRequest(
            completion: @escaping(KYCVerificationCheckerResult) -> Void
            ) {
            
            self.accountsApi.requestChangeRoleRequests(
                filters: .with(.requestor(self.accountId)),
                include: ["request_details"],
                pagination: RequestPagination(.single(index: 0, limit: 10, order: .descending)),
                completion: { [weak self] (result) in
                    switch result {
                        
                    case .failure:
                        self?.reload(completion: completion)
                        
                    case .success(let document):
                        guard let request = document.data?.first else {
                            self?.reload(completion: completion)
                            return
                        }
                        
                        self?.handleReviewableRequest(
                            request,
                            completion: completion
                        )
                    }
            })
        }
        
        private func handleReviewableRequest(
            _ request: TokenDSDK.ReviewableRequestResource,
            completion: @escaping(KYCVerificationCheckerResult) -> Void
            ) {
            
            guard let requestDetailsType = request.requestDetails?.requestDetailsType else {
                return
            }
            
            switch requestDetailsType {
                
            case .changeRoleRequestDetails:
                switch request.stateValue {
                    
                case .approved:
                    completion(.verified)
                    
                case .canceled,
                     .pending,
                     .permanentlyRejected,
                     .rejected,
                     .unknown:
                    
                    self.fetchRequest(completion: completion)
                }
                
            default:
                break
            }
        }
        
        private func reload(completion: @escaping(KYCVerificationCheckerResult) -> Void) {
            
            self.dispatchQueue.asyncAfter(
                deadline: .now() + .seconds(1),
                execute: { [weak self] in
                    self?.fetchRequest(completion: completion)
            })
        }
    }
}

extension KYC.VerificationChecker: KYC.VerificationCheckerProtocol {
    
    public func startToCheck(
        completion: @escaping(KYCVerificationCheckerResult) -> Void
        ) {
        
        self.fetchRequest(completion: completion)
    }
}
