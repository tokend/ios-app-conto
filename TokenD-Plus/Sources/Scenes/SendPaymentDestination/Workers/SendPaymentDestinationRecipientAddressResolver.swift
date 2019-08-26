import Foundation
import TokenDWallet
import TokenDSDK

public enum RecipientAddressResolverResult {
    public enum AddressResolveError: Swift.Error, LocalizedError {
        case invalidEmail
        case other(Swift.Error)
        
        public var errorDescription: String? {
            switch self {
            case .invalidEmail:
                return Localized(.there_is_not_any_user_with_such_an_email_was_found)
            case .other(let errors):
                let message = errors.localizedDescription
                return Localized(
                    .request_error,
                    replace: [
                        .request_error_replace_message: message
                    ]
                )
            }
        }
    }
    
    case succeeded(recipientAddress: String)
    case userIsNotExist(proxyAccountId: String)
    case failed(AddressResolveError)
}

public protocol SendPaymentDestinationRecipientAddressResolverProtocol {
    func resolve(
        recipientAddress: String,
        completion: @escaping (_ result: RecipientAddressResolverResult) -> Void
    )
}

extension SendPaymentDestination {
    public typealias RecipientAddressResolver = SendPaymentDestinationRecipientAddressResolverProtocol
    
    public class RecipientAddressResolverWorker: RecipientAddressResolver {
        
        // MARK: - Private properties
        
        private let generalApi: GeneralApi
        private let integrationsApi: IntegrationsApiV3
        
        // MARK: -
        
        public init(
            generalApi: GeneralApi,
            integrationsApi: IntegrationsApiV3
            ) {
            
            self.generalApi = generalApi
            self.integrationsApi = integrationsApi
        }
        
        // MARK: - RecipientAddressResolver
        
        public func resolve(
            recipientAddress: String,
            completion: @escaping (_ result: RecipientAddressResolverResult) -> Void
            ) {
            
            let email = recipientAddress.lowercased()
            guard self.validateEmail(email) else {
                completion(.failed(.invalidEmail))
                return
            }
            
            self.generalApi.requestIdentities(
                filter: .email(email),
                completion: { (result) in
                    switch result {
                        
                    case .failed(let error):
                        completion(.failed(.other(error)))
                        
                    case .succeeded(let response):
                        guard let identity = response.first(where: { (identity) -> Bool in
                            return identity.attributes.email == email
                        }) else {
                            self.fetchProxyAccountId(completion: completion)
                            return
                        }
                        
                        completion(.succeeded(recipientAddress: identity.attributes.address))
                    }
            })
        }
        
        // MARK: - Private
        
        private func validateEmail(_ email: String) -> Bool {
            return true
        }
        
        private func fetchProxyAccountId(
            completion: @escaping (_ result: RecipientAddressResolverResult) -> Void
            ) {
            
            self.integrationsApi.requestProxyPaymentAccount { (result) in
                switch result {
                    
                case .failure(let error):
                    completion(.failed(.other(error)))
                    
                case .success(let document):
                    guard let account = document.data,
                        let accountId = account.id else {
                            return
                    }
                    completion(.userIsNotExist(proxyAccountId: accountId))
                }
            }
        }
    }
}
