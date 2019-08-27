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
        
        self.generalApi.requestIdentities(
            filter: .accountId(accountId),
            completion: { result in
                switch result {
                    
                case .failed(let error):
                    completion(.error(error))
                    
                case .succeeded(let identities):
                    guard let number = identities.first(where: { (identity) -> Bool in
                        return identity.attributes.phoneNumber != nil
                    })?.attributes.phoneNumber else {
                        completion(.didNotSet)
                        return
                    }
                    completion(.value(number))
                }
        })
    }
}
