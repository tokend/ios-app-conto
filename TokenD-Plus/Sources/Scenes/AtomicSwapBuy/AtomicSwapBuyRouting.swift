import Foundation

extension AtomicSwapBuy {
    
    struct Routing {
        let onShowProgress: () -> Void
        let onHideProgress: () -> Void
        let onShowError: (_ erroMessage: String) -> Void
        let onPresentPicker: (
        _ options: [String],
        _ onSelect: @escaping (_ balanceId: String) -> Void
        ) -> Void
        let onAtomicSwapFiatBuyAction: ((_ ask: Model.AtomicSwapPaymentUrl) -> Void)
        let onAtomicSwapCryptoBuyAction: ((_ ask: Model.AtomicSwapInvoiceViewModel) -> Void)
    }
}
