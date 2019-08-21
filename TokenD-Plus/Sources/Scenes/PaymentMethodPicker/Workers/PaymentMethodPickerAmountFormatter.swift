import Foundation

public protocol PaymentMethodPickerAmountFormatterProtocol {
    func formatAmount(
        _ amount: Decimal,
        currency: String
        ) -> String
    
    func assetAmountToString(_ amount: Decimal) -> String
}

extension PaymentMethodPicker {
    public typealias AmountFormatterProtocol = PaymentMethodPickerAmountFormatterProtocol
    
    public class AmountFormatter: SharedAmountFormatter { }
}

extension PaymentMethodPicker.AmountFormatter: PaymentMethodPicker.AmountFormatterProtocol {
    
}
