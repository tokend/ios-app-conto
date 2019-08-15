import Foundation

public enum PaymentMethodPaymentSenderResult {
    case success(PaymentMethod.Model.AtomicSwapPaymentUrl)
    case error(Swift.Error)
}
public protocol PaymentMethodPaymentSenderProtocol {
    func sendPayment(
        completion: @escaping (PaymentMethodPaymentSenderResult) -> Void
    )
}

extension PaymentMethod {
    public typealias PaymentSenderProtocol = PaymentMethodPaymentSenderProtocol
    
    public class FiatPaymentSender {
        
    }
}

extension PaymentMethod.FiatPaymentSender: PaymentMethod.PaymentSenderProtocol {
    
    public func sendPayment(
        completion: @escaping (PaymentMethodPaymentSenderResult) -> Void
        ) {
        
    }
}
