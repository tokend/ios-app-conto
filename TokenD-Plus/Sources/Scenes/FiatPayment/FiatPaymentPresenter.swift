import Foundation

public protocol FiatPaymentPresentationLogic {
    typealias Event = FiatPayment.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
}

extension FiatPayment {
    public typealias PresentationLogic = FiatPaymentPresentationLogic
    
    @objc(FiatPaymentPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = FiatPayment.Event
        public typealias Model = FiatPayment.Model
        
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
    }
}

extension FiatPayment.Presenter: FiatPayment.PresentationLogic {
    
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let amount = self.amountFormatter.assetAmountToString(
            response.amount,
            currency: response.asset
        )
        let viewModel = Event.ViewDidLoad.ViewModel(amount: amount)
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
}
