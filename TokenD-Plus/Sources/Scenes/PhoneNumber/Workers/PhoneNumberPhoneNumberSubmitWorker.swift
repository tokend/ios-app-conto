import Foundation
import TokenDSDK

public enum PhoneNumberSubmitResult {
    case success
    case error(Swift.Error)
}
public protocol PhoneNumberPhoneNumberSubmitWorkerProtocol {
    func submitNumber(
        number: String,
        completion: @escaping (PhoneNumberSubmitResult) -> Void
        )
}

extension PhoneNumber {
    public typealias PhoneNumberSubmitWorkerProtocol = PhoneNumberPhoneNumberSubmitWorkerProtocol
    
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

extension PhoneNumber.PhoneNumberSubmitWorker: PhoneNumber.PhoneNumberSubmitWorkerProtocol {
    
    public func submitNumber(
        number: String,
        completion: @escaping (PhoneNumberSubmitResult) -> Void
        ) {
        
        self.generalApi.requestSetPhone(
            accountId: self.accountId,
            phone: .init(phone: number),
            completion: { (result) in
                switch result {
                    
                case .failed(let error):
                    completion(.error(error))
                    
                case .tfaFailed:
                    completion(.error(PhoneNumber.Model.Error.invalidCode))
                    
                case .succeeded:
                    completion(.success)
                }
        })
    }
}
