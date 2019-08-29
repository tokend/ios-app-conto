import Foundation

protocol AtomicSwapBuyAmountFormatterProtocol {
    func formatAmount(
        _ amount: Decimal,
        currency: String
        ) -> String
    
    func assetAmountToString(_ amount: Decimal) -> String
}

extension AtomicSwapBuy {
    typealias AmountFormatterProtocol = AtomicSwapBuyAmountFormatterProtocol
    
    class AmountFormatter: SharedAmountFormatter { }
}

extension AtomicSwapBuy.AmountFormatter: AtomicSwapBuy.AmountFormatterProtocol {
    
}
