import Foundation
import TokenDSDK

public enum PhoneNumberIdentifyResult {
    case didNotSet
    case number(String)
    case error(Swift.Error)
}
public protocol PhoneNumberPhoneNumberIdentifierProtocol {
    func identifyBy(
        accountId: String,
        completion: @escaping(PhoneNumberIdentifyResult) -> Void
        )
}

extension PhoneNumber {
    public typealias PhoneNumberIdentifierProtocol = PhoneNumberPhoneNumberIdentifierProtocol
    
    public class PhoneNumberIdentifier {
        
        // MARK: - Private properties
        
        private let generalApi: GeneralApi
        
        // MARK: -
        
        init(generalApi: GeneralApi) {
            self.generalApi = generalApi
        }
        
        // MARK: - Private
    }
}

extension PhoneNumber.PhoneNumberIdentifier: PhoneNumber.PhoneNumberIdentifierProtocol {
    
    public func identifyBy(
        accountId: String,
        completion: @escaping (PhoneNumberIdentifyResult) -> Void
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
                    completion(.number(number))
                }
        })
    }
}
