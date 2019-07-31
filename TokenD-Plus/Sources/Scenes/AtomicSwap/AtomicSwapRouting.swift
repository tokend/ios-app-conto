import Foundation

extension AtomicSwap {
    public struct Routing {
        let showLoading: () -> Void
        let hideLoading: () -> Void
        let showShadow: () -> Void
        let hideShadow: () -> Void
        let onBuyAction: (_ model: Model.Ask) -> Void
    }
}
