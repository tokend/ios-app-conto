import Foundation

extension Polls {
    
    public struct Routing {
        let showError: (_ message: String) -> Void
        let showLoading: () -> Void
        let hideLoading: () -> Void
        let showShadow: () -> Void
        let hideShadow: () -> Void
    }
}
