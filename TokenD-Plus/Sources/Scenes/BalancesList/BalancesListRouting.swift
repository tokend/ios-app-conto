import Foundation

extension BalancesList {
    public struct Routing {
        let onBalanceSelected: (_ balanceId: String) -> Void
        let showProgress: () -> Void
        let hideProgress: () -> Void
        let showShadow: () -> Void
        let hideShadow: () -> Void
        let showReceive: () -> Void
        let showCreateRedeem: () -> Void
        let showAcceptRedeem: () -> Void
        let showSendPayment: () -> Void
        let showBuy: (_ model: Model.Ask) -> Void
    }
}
