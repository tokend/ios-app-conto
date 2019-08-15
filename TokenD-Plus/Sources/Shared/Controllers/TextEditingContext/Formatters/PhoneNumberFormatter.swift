import Foundation

class PhoneNumberFormatter: ValueFormatter<String> {
    
    private let validChars
    
    // MARK: - Override
    
    override func valueFromString(_ string: String?) -> Decimal? {
        guard var string = string else {
            return nil
        }
        
        string = string.replacingOccurrences(
            of: ",",
            with: self.decimalSeparator
        )
        let invalidCharsRange = string.rangeOfCharacter(from: self.invalidCharSet)
        if invalidCharsRange != nil {
            return nil
        }
        
        let components = string.components(separatedBy: self.decimalSeparator)
        let decimalSeparatorCheck = components.count <= 2
        
        guard decimalSeparatorCheck else {
            return nil
        }
        
        if components.count == 2 && components[1].count > 6 {
            return nil
        }
        
        let valueDecimal = Decimal(string: string)
        return valueDecimal
    }
}
