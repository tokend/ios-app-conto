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
        
        self.generalApi.requestSetTelegram(
            accountId: self.accountId,
            telegram: .init(username: value),
            completion: { (result) in
                switch result {
                    
                case .failed(let error):
                    completion(.error(error))
                    
                case .tfaFailed:
                    completion(.error(Identity.Event.SetAction.SetTelegramError.tfaFailed))
                    
                case .succeeded:
                    completion(.success)
                }
        })
    }
}
