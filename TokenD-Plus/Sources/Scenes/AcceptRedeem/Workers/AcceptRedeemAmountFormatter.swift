import Foundation

public protocol AcceptRedeemAmountFormatterProtocol {
    func format(amount: UInt64, precision: Int64) -> UInt64
}

extension AcceptRedeem {
    public typealias AmountFormatterProtocol = AcceptRedeemAmountFormatterProtocol
    
    public class AmountFormatter: AcceptRedeemAmountFormatterProtocol {
        
        public func format(amount: UInt64, precision: Int64) -> UInt64 {
            return amount / UInt64(precision)
        }
    }
}
