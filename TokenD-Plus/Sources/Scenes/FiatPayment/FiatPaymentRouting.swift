import Foundation

extension FiatPayment {
    public struct Routing {
        let showLoading: () -> Void
        let hideLoading: () -> Void
        let onChoosePaymentOption: () -> Void
    }
}
