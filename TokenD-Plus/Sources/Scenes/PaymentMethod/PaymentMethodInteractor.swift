import Foundation

public protocol PaymentMethodBusinessLogic {
    typealias Event = PaymentMethod.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
}

extension PaymentMethod {
    public typealias BusinessLogic = PaymentMethodBusinessLogic
    
    @objc(PaymentMethodInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = PaymentMethod.Event
        public typealias Model = PaymentMethod.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let paymentMethodsFetcher: PaymentMethodsFetcherProtocol
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            paymentMethodsFetcher: PaymentMethodsFetcherProtocol
            ) {
            
            self.presenter = presenter
            self.paymentMethodsFetcher = paymentMethodsFetcher
        }
    }
}

extension PaymentMethod.Interactor: PaymentMethod.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        let response = Event.ViewDidLoad.Response()
        self.presenter.presentViewDidLoad(response: response)
    }
}
