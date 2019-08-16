import Foundation

public protocol PhoneNumberPhoneNumberValidatorProtocol {
    func validate(number: String) -> Bool
}

extension PhoneNumber {
    public typealias PhoneNumberValidatorProtocol = PhoneNumberPhoneNumberValidatorProtocol
    
    public class PhoneNumberValidator: PhoneNumberValidatorProtocol {
        
        // MARK: - Private properties
        
        private let regex: NSRegularExpression? = try? NSRegularExpression(
            pattern: "[+][0-9]{1,3}[0-9]{1,3}[0-9]{3}[0-9]{3,4}",
            options: .caseInsensitive
        )
        
        // MARK: - PhoneNumberValidatorProtocol
        
        public func validate(number: String) -> Bool {
            guard let regex = self.regex else {
                return false
            }
            let range = NSRange(location: 0, length: number.utf16.count)
            return regex.firstMatch(in: number, range: range) != nil
        }
    }
}
