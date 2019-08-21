import Foundation

public protocol PaymentMethodPickerPresentationLogic {
    typealias Event = PaymentMethodPicker.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
}

extension PaymentMethodPicker {
    public typealias PresentationLogic = PaymentMethodPickerPresentationLogic
    
    @objc(PaymentMethodPickerPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = PaymentMethodPicker.Event
        public typealias Model = PaymentMethodPicker.Model
        
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
        
        private func getMethodsViewModels(models: [Model.PaymentMethodModel]) -> [MethodCell.ViewModel] {
            
            return models.map({ (method) -> MethodCell.ViewModel in
                let amount = self.amountFormatter.assetAmountToString(method.amount)
                let toPayAmount = Localized(
                    .amount_to_pay,
                    replace: [
                        .amount_to_pay_replace_amount: amount
                    ]
                )
                return MethodCell.ViewModel(
                    asset: method.assetName,
                    toPayAmount: toPayAmount
                )
            })
        }
    }
}

extension PaymentMethodPicker.Presenter: PaymentMethodPicker.PresentationLogic {
    
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let methods = self.getMethodsViewModels(models: response.methods)
        let viewModel = Event.ViewDidLoad.ViewModel(methods: methods)
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
}
