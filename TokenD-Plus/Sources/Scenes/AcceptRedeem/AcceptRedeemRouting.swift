import Foundation

extension AcceptRedeem {
    public struct Routing {
        let showProgress: () -> Void
        let hideProgress: () -> Void
        let showError: (_ message: String) -> Void
        let onConfirmRedeem: (AcceptRedeem.Model.RedeemModel) -> Void
    }
}
