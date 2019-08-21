import Foundation

public protocol PhoneNumberPresentationLogic {
    typealias Event = PhoneNumber.Event
    
    func presentSetNumberAction(response: Event.SetNumberAction.Response)
    func presentSсeneUpdated(response: Event.SceneUpdated.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
    func presentError(response: Event.Error.Response)
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
    
    public func presentSсeneUpdated(response: Event.SceneUpdated.Response) {
        let buttonTitle: String
        let buttonIsEnable: Bool
        switch response.state {
            
        case .isNotSet:
            buttonTitle = Localized(.set_phone_number)
            buttonIsEnable = response.number?.isEmpty ?? false
            
        case .sameWithIdentity:
            buttonTitle = Localized(.change_phone)
            buttonIsEnable = false
            
        case .updated:
            buttonTitle = Localized(.change_phone)
            buttonIsEnable = true
        }
        let buttonAppearence = Model.ButtonAppearence(
            isEnabled: buttonIsEnable,
            title: buttonTitle
        )
        let viewModel = Event.SceneUpdated.ViewModel(
            number: response.number,
            buttonAppearence: buttonAppearence
        )
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displaySceneUpdated(viewModel: viewModel)
        }
    }
    
    public func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayLoadingStatusDidChange(viewModel: viewModel)
        }
    }
    
    public func presentError(response: Event.Error.Response) {
        let viewModel = Event.Error.ViewModel(error: response.error.localizedDescription)
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayError(viewModel: viewModel)
        }
    }
}

extension PhoneNumber.Model.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        case .emptyNumber:
            return Localized(.empty_number_field)
            
        case .invalidCode:
            return Localized(.invalid_code)
            
        case .numberIsNotValid:
            return Localized(.invalid_phone_number)
        }
    }
}
