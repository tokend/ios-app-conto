import Foundation

class PhoneNumberFormatter: ValueFormatter<String> {
    
    private let validCharacters: String = "0123456789"
    
    // MARK: - Override
    
    override func valueFromString(_ string: String?) -> String? {
        guard let string = string else {
            return nil
        }
        var isPhoneNumberValid = true
        for number in string {
            if !validCharacters.contains(number) {
                isPhoneNumberValid = false
                break
            }
        }
        
        return isPhoneNumberValid ? string : nil
    }
}
