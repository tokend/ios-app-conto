import Foundation

extension FiatPayment {
    public struct Routing {
        let showComplete: () -> Void
        let showLoading: () -> Void
        let hideLoading: () -> Void
    }
}
