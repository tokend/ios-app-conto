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
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension FiatPayment.Presenter: FiatPayment.PresentationLogic {
    
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let urlRequest = URLRequest(url: response.url)
        let viewModel = Event.ViewDidLoad.ViewModel(request: urlRequest)
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
}
