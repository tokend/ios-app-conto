import Foundation

extension PaymentMethodPicker {
    public struct Routing {
        let onPaymentMethodPicked: (_ asset: String) -> Void
    }
}
