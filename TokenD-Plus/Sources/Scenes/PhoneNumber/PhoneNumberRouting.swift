import Foundation

extension PhoneNumber {
    public struct Routing {
        let showError: (_ message: String) -> Void
        let showMessage: (_ message: String) -> Void
        let showLoading: () -> Void
        let hideLoading: () -> Void
    }
}
