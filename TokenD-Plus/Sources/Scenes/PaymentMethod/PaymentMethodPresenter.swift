import Foundation

public protocol PaymentMethodPresentationLogic {
    typealias Event = PaymentMethod.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
}

extension PaymentMethod {
    public typealias PresentationLogic = PaymentMethodPresentationLogic
    
    @objc(PaymentMethodPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = PaymentMethod.Event
        public typealias Model = PaymentMethod.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension PaymentMethod.Presenter: PaymentMethod.PresentationLogic {
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let viewModel = Event.ViewDidLoad.ViewModel()
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
}
