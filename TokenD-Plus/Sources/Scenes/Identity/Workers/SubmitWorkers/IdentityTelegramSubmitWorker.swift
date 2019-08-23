import Foundation
import TokenDSDK


extension Identity {
    
    public typealias TelegramIdentitySubmitWorkerProtocol = IdentityIdentitySubmitWorkerProtocol
    
    public class TelegramSubmitWorker {
        
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

extension Identity.TelegramSubmitWorker: Identity.TelegramIdentitySubmitWorkerProtocol {
    
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
                    completion(.error(Identity.Event.SetNumberAction.Error.invalidCode))
                    
                case .succeeded:
                    completion(.success)
                }
        })
    }
}
