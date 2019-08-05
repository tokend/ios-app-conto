import Foundation

public protocol PaymentMethodPresentationLogic {
    typealias Event = PaymentMethod.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
    func presentSelectPaymentMethod(response: Event.SelectPaymentMethod.Response)
    func presentPaymentMethodSelected(response: Event.PaymentMethodSelected.Response)
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
                asset: method.asset,
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
            currency: response.baseAsset
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
}
