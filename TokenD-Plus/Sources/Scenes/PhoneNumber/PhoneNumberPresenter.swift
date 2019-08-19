import Foundation

public protocol PhoneNumberPresentationLogic {
    typealias Event = PhoneNumber.Event
    
    func presentSetNumberAction(response: Event.SetNumberAction.Response)
}

extension PhoneNumber {
    public typealias PresentationLogic = PhoneNumberPresentationLogic
    
    @objc(PhoneNumberPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = PhoneNumber.Event
        public typealias Model = PhoneNumber.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension PhoneNumber.Presenter: PhoneNumber.PresentationLogic {
    
    public func presentSetNumberAction(response: Event.SetNumberAction.Response) {
        let viewModel: Event.SetNumberAction.ViewModel
        switch response {
            
        case .error(let error):
            viewModel = .error(error.localizedDescription)
            
        case .success:
            viewModel = .success("Success")
            
        case .loaded:
            viewModel = .loaded
            
        case .loading:
            viewModel = .loading
        }
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displaySetNumberAction(viewModel: viewModel)
        }
    }
}
