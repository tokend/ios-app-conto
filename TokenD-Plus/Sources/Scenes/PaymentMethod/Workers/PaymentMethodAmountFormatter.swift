import Foundation

public protocol PaymentMethodAmountFormatterProtocol {
    func formatAmount(
        _ amount: Decimal,
        currency: String
        ) -> String
    
    func assetAmountToString(_ amount: Decimal) -> String
}

extension PaymentMethod {
    public typealias AmountFormatterProtocol = PaymentMethodAmountFormatterProtocol
    
    public class AmountFormatter: SharedAmountFormatter { }
}

extension PaymentMethod.AmountFormatter: PaymentMethod.AmountFormatterProtocol {
    
}
