import UIKit

public protocol AmountConverterProtocol {
    func convertDecimalToUInt64(value: Decimal, precision: Int64) -> UInt64
    func convertDecimalToInt64(value: Decimal, precision: Int64) -> Int64
    func convertUInt64ToDecimal(value: UInt64, precision: Int64) -> Decimal
}

public class AmountConverter: AmountConverterProtocol {
    
    // MARK: - Private proverties
    
    private let behavior: NSDecimalNumberBehaviors = DecimalFloorRoundingBehavior()
    
    // MARK: - AmountConverterProtocol
    
    public func convertDecimalToUInt64(value: Decimal, precision: Int64) -> UInt64 {
        let amount = NSDecimalNumber(decimal: value * Decimal(precision)).rounding(accordingToBehavior: self.behavior)
        return UInt64(exactly: amount) ?? 0
    }
    
    public func convertDecimalToInt64(value: Decimal, precision: Int64) -> Int64 {
        let amount = NSDecimalNumber(decimal: value * Decimal(precision)).rounding(accordingToBehavior: self.behavior)
        return Int64(exactly: amount) ?? 0
    }
    
    public func convertUInt64ToDecimal(value: UInt64, precision: Int64) -> Decimal {
        return Decimal(value) / Decimal(precision)
    }
}
