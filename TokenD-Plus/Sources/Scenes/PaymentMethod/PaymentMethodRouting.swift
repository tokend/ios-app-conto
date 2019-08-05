import Foundation

extension PaymentMethod {
    public struct Routing {
        let onPickPaymentMethod: (
        _ methods: [Model.PaymentMethod],
        _ completion: (@escaping(_ asset: String) -> Void)
        ) -> Void
        let showError: (_ message: String) -> Void
        let showAtomicSwapInvoice: (Model.AtomicSwapInvoice) -> Void
        let showLoading: () -> Void
        let hideLoading: () -> Void
    }
}
