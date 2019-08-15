import Foundation

extension KYC {
    public struct Routing {
        let showLoading: () -> Void
        let hideLoading: () -> Void
        let showError: (_ message: String) -> Void
        let showMessage: (_ message: String) -> Void
        let showValidationError: (_ message: String) -> Void
        let showOnApproved: () -> Void
    }
}
