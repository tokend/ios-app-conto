import Foundation

extension PaymentMethod {
    public struct Routing {
        let onPickPaymentMethod: (
        _ methods: [Model.PaymentMethod],
        _ completion: (@escaping(_ asset: String) -> Void)
        ) -> Void
    }
}
