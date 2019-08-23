import Foundation
import TokenDSDK


extension Identity {
    public typealias TelegramIdentifierProtocol = IdentityIdentifierProtocol
    
    public class TelegramIdentifier {
        
        // MARK: - Private properties
        
        private let generalApi: GeneralApi
        
        // MARK: -
        
        init(generalApi: GeneralApi) {
            self.generalApi = generalApi
        }
        
        // MARK: - Private
    }
}

extension Identity.TelegramIdentifier: Identity.TelegramIdentifierProtocol {
    
    public func identifyBy(
        accountId: String,
        completion: @escaping (IdentifyResult) -> Void
        ) {
            completion(.didNotSet)
    }
}
