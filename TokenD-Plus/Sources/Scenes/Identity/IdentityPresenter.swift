import Foundation

public protocol PhoneNumberPresentationLogic {
    typealias Event = Identity.Event
    
    func presentSetAction(response: Event.SetAction.Response)
    func presentSсeneUpdated(response: Event.SceneUpdated.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
    func presentError(response: Event.Error.Response)
}

extension Identity {
    public typealias PresentationLogic = PhoneNumberPresentationLogic
    
    @objc(PhoneNumberPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = Identity.Event
        public typealias Model = Identity.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
        
        // MARK: - Private
        
        private func getSetTitle(sceneType: Model.SceneType) -> String {
            switch sceneType {
                
            case .phoneNumber:
                return Localized(.set_phone_number)
                
            case .telegram:
                return Localized(.set_telegram)
            }
        }
        
        private func getChangeTitle(sceneType: Model.SceneType) -> String {
            switch sceneType {
                
            case .phoneNumber:
                return Localized(.change_phone)
                
            case .telegram:
                return Localized(.change_telegram)
            }
        }
    }
}

extension Identity.Presenter: Identity.PresentationLogic {
    
    public func presentSetAction(response: Event.SetAction.Response) {
        let viewModel: Event.SetAction.ViewModel
        switch response {
            
        case .error(let error):
            viewModel = .error(error.localizedDescription)
            
        case .success(let sceneType):
            let message: String
            switch sceneType {
            case .phoneNumber:
                message = Localized(.your_phone_number_has_been_successfully_set)
            case .telegram:
                message = Localized(.your_telegram_username_has_been_successfully_set)
            }
            viewModel = .success(message)
            
        case .loaded:
            viewModel = .loaded
            
        case .loading:
            viewModel = .loading
        }
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displaySetAction(viewModel: viewModel)
        }
    }
    
    public func presentSсeneUpdated(response: Event.SceneUpdated.Response) {
        let buttonTitle: String
        let buttonIsEnable: Bool
        switch response.state {
            
        case .isNotSet:
            buttonTitle = self.getSetTitle(sceneType: response.sceneType)
            if let value = response.value {
                buttonIsEnable = !value.isEmpty
            } else {
                buttonIsEnable = false
            }
            
        case .sameWithIdentity:
            buttonTitle = self.getChangeTitle(sceneType: response.sceneType)
            buttonIsEnable = false
            
        case .updated:
            buttonTitle = self.getChangeTitle(sceneType: response.sceneType)
            buttonIsEnable = true
        }
        let buttonAppearence = Model.ButtonAppearence(
            isEnabled: buttonIsEnable,
            title: buttonTitle
        )
        let viewModel = Event.SceneUpdated.ViewModel(
            value: response.value,
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

extension Identity.Event.SetAction.SetNumberError: LocalizedError {
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
