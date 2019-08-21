import Foundation

public protocol AtomicSwapAmountFormatterProtocol {
    func formatAmount(_ amount: Decimal, currency: String) -> String
    func assetAmountToString(_ amount: Decimal) -> String
}

extension AtomicSwap {
    public typealias AmountFormatterProtocol = AtomicSwapAmountFormatterProtocol
}

extension AtomicSwap {
    public class AmountFormatter: SharedAmountFormatter { }
}

extension AtomicSwap.AmountFormatter: AtomicSwap.AmountFormatterProtocol {
    
}
