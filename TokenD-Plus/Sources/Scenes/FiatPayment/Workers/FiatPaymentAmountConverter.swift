import Foundation

public protocol FiatPaymentAmountFormatterProtocol {
    func assetAmountToString(_ amount: Decimal, currency: String) -> String
}

extension FiatPayment {
    public typealias AmountFormatterProtocol = FiatPaymentAmountFormatterProtocol
    
    public class AmountFormatter: SharedAmountFormatter {}
}

extension FiatPayment.AmountFormatter: FiatPayment.AmountFormatterProtocol {}
