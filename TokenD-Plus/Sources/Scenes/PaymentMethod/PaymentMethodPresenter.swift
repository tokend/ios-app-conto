import Foundation

public protocol PaymentMethodPresentationLogic {
    typealias Event = PaymentMethod.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
    func presentSelectPaymentMethod(response: Event.SelectPaymentMethod.Response)
    func presentPaymentMethodSelected(response: Event.PaymentMethodSelected.Response)
    func presentPaymentAction(response: Event.PaymentAction.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
}

extension PaymentMethod {
    public typealias PresentationLogic = PaymentMethodPresentationLogic
    
    @objc(PaymentMethodPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = PaymentMethod.Event
        public typealias Model = PaymentMethod.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        private let amountFormatter: AmountFormatterProtocol
        
        // MARK: -
        
        public init(
            presenterDispatch: PresenterDispatch,
            amountFormatter: AmountFormatterProtocol
            ) {
            
            self.presenterDispatch = presenterDispatch
            self.amountFormatter = amountFormatter
        }
        
        // MARK: - Private
        
        private func getMethodViewModel(method: Model.PaymentMethod) -> Model.PaymentMethodViewModel {
            let amount = self.amountFormatter.assetAmountToString(method.amount)
            let toPayAmount = Localized(
                .amount_to_pay,
                replace: [
                    .amount_to_pay_replace_amount: amount
                ]
            )
            return Model.PaymentMethodViewModel(
                asset: method.assetName,
                toPayAmount: toPayAmount
            )
        }
        
        private func getMethodsViewModels(models: [Model.PaymentMethod]) -> [Model.PaymentMethodViewModel] {
            return models.map({ (method) -> Model.PaymentMethodViewModel in
                return self.getMethodViewModel(method: method)
            })
        }
    }
}

extension PaymentMethod.Presenter: PaymentMethod.PresentationLogic {
    
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let baseAmount = self.amountFormatter.formatAmount(
            response.baseAmount,
            currency: response.baseAssetName
        )
        let buyAmount = Localized(
            .buy_asset,
            replace: [
                .buy_asset_replace_asset: baseAmount
            ]
        )
        var selectedMethod: Model.PaymentMethodViewModel?
        if let method = response.selectedMethod {
            selectedMethod = self.getMethodViewModel(method: method)
        }
        let viewModel = Event.ViewDidLoad.ViewModel(
            buyAmount: buyAmount,
            selectedMethod: selectedMethod
        )
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
    
    public func presentSelectPaymentMethod(response: Event.SelectPaymentMethod.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displaySelectPaymentMethod(viewModel: viewModel)
        }
    }
    
    public func presentPaymentMethodSelected(response: Event.PaymentMethodSelected.Response) {
        let method = self.getMethodViewModel(method: response.method)
        let viewModel = Event.PaymentMethodSelected.ViewModel(method: method)
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayPaymentMethodSelected(viewModel: viewModel)
        }
    }
    
    public func presentPaymentAction(response: Event.PaymentAction.Response) {
        let viewModel: Event.PaymentAction.ViewModel
        
        switch response {
        case .error(let error):
            viewModel = .error(error.localizedDescription)
            
        case .invoce(let invoice):
            let amount = self.amountFormatter.formatAmount(
                invoice.amount,
                currency: invoice.asset
            )
            let invoiceViewModel = Model.AtomicSwapInvoiceViewModel(
                address: invoice.address,
                amount: amount
            )
            viewModel = .invoce(invoiceViewModel)
        }
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayPaymentAction(viewModel: viewModel)
        }
    }
    
    public func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayLoadingStatusDidChange(viewModel: viewModel)
        }
    }
}

extension PaymentMethod.Model.PaymentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        case .askIsNotFound:
            return Localized(.ask_is_not_found)
            
        case .createBidRequestIsNotFound:
            return Localized(.create_bid_request_is_not_found)
            
        case .externalDetailsAreNotFound:
            return Localized(.external_details_are_not_found)
            
        case .failedToBuildTransaction:
            return Localized(.failed_to_build_transaction)
            
        case .failedToDecodeSourceAccountId:
            return Localized(.failed_to_decode_account_id)
            
        case .failedToFecthAskId:
            return Localized(.failed_to_fetch_ask_id)
            
        case .failedToFetchCreateBidRequest:
            return Localized(.failed_to_fetch_create_bid_request)
            
        case .failedToSendTransaction:
            return Localized(.failed_to_send_transaction)
            
        case .other(let error):
            return error.localizedDescription
            
        case .paymentIsRejected:
            return Localized(.payment_rejected)
        }
    }
}
