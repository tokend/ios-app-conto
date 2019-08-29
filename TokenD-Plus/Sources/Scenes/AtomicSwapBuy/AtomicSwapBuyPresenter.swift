import Foundation

protocol AtomicSwapBuyPresentationLogic {
    
    typealias Event = AtomicSwapBuy.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
    func presentSelectQuoteAsset(response: Event.SelectQuoteAsset.Response)
    func presentQuoteAssetSelected(response: Event.QuoteAssetSelected.Response)
    func presentEditAmount(response: Event.EditAmount.Response)
    func presentAtomicSwapBuyAction(response: Event.AtomicSwapBuyAction.Response)
}

extension AtomicSwapBuy {
    typealias PresentationLogic = AtomicSwapBuyPresentationLogic
    
    struct Presenter {
        
        typealias Model = AtomicSwapBuy.Model
        typealias Event = AtomicSwapBuy.Event
        
        private let presenterDispatch: PresenterDispatch
        private let amountFormatter: AmountFormatterProtocol
        
        init(
            presenterDispatch: PresenterDispatch,
            amountFormatter: AmountFormatterProtocol
            ) {
            self.presenterDispatch = presenterDispatch
            self.amountFormatter = amountFormatter
        }
        
        // MARK: - Private
        
        private func getAtomicSwapPaymentViewType(model: Model.AtomicSwapPaymentType) -> Model.AtomicSwapPaymentViewType {
            
            switch model {
            case .crypto(let invoce):
                let amount = self.amountFormatter.assetAmountToString(invoce.amount) + " \(invoce.asset)"
                let invoceViewModel = Model.AtomicSwapInvoiceViewModel(
                    address: invoce.address,
                    amount: amount
                )
                return .crypto(invoceViewModel)
                
            case .fiat(let paymentUrl):
                return .fiat(paymentUrl)
            }
        }
    }
}

extension AtomicSwapBuy.Presenter: AtomicSwapBuy.PresentationLogic {
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let availableAmount = self.amountFormatter.assetAmountToString(response.availableAmount)
        let viewModel = Event.ViewDidLoad.ViewModel(
            availableAmount: availableAmount,
            availableAsset: response.baseAsset,
            selectedQuoteAsset: response.selectedQuoteAsset
        )
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
    
    func presentSelectQuoteAsset(response: Event.SelectQuoteAsset.Response) {
        let viewModel = Event.SelectQuoteAsset.ViewModel(quoteAssets: response.quoteAssets)
        self.presenterDispatch.display { displayLogic in
            displayLogic.displaySelectQuoteAsset(viewModel: viewModel)
        }
    }
    
    func presentQuoteAssetSelected(response: Event.QuoteAssetSelected.Response) {
        let viewModel = response
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayQuoteAssetSelected(viewModel: viewModel)
        }
    }
    
    func presentEditAmount(response: Event.EditAmount.Response) {
        let viewModel = Event.EditAmount.ViewModel(amountValid: response.amountValid)
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayEditAmount(viewModel: viewModel)
        }
    }
    
    func presentAtomicSwapBuyAction(response: Event.AtomicSwapBuyAction.Response) {
        let viewModel: Event.AtomicSwapBuyAction.ViewModel
        switch response {
            
        case .loaded:
            viewModel = .loaded
            
        case .loading:
            viewModel = .loading
            
        case .failed(let error):
            viewModel = .failed(errorMessage: error.localizedDescription)
            
        case .succeeded(let paymentType):
            let paymentViewType = self.getAtomicSwapPaymentViewType(model: paymentType)
            viewModel = .succeeded(paymentViewType)
        }
        
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayAtomicSwapBuyAction(viewModel: viewModel)
        }
    }
}
