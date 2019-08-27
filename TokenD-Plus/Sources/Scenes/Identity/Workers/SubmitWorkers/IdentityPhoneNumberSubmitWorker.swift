import Foundation
import TokenDSDK


extension Identity {
    
    public typealias IdentitySubmitWorkerProtocol = IdentityIdentitySubmitWorkerProtocol
    
    public class PhoneNumberSubmitWorker {
        
        // MARK: - Private properties
        
        private let generalApi: GeneralApi
        private let accountId: String
        
        // MARK: -
        
        init(
            generalApi: GeneralApi,
            accountId: String
            ) {
            
            self.generalApi = generalApi
            self.accountId = accountId
        }
    }
}

extension Identity.PhoneNumberSubmitWorker: Identity.IdentitySubmitWorkerProtocol {
    
    public func submitIdentity(
        value: String,
        completion: @escaping (IdentitySubmitResult) -> Void
        ) {
        
        self.generalApi.requestSetPhone(
            accountId: self.accountId,
            phone: .init(phone: value),
            completion: { (result) in
                switch result {
                    
                case .failed(let error):
                    completion(.error(error))
                    
                case .tfaFailed:
                    completion(.error(Identity.Event.SetAction.SetNumberError.tfaFailed))
                    
                case .succeeded:
                    completion(.success)
                }
        })
    }
}
