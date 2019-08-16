import Foundation


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
        
        private let accountId: String
        
        // MARK: -
        
        init(accountId: String) {
            self.accountId = accountId
        }
        
    }
}

extension PhoneNumber.PhoneNumberSubmitWorker: PhoneNumber.PhoneNumberSubmitWorkerProtocol {
    
    public func submitNumber(
        number: String,
        completion: @escaping (PhoneNumberSubmitResult) -> Void
        ) {
        
        
    }
}
