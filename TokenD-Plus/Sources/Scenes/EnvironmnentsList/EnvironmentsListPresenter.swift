import Foundation

public protocol EnvironmentsListPresentationLogic {
    typealias Event = EnvironmentsList.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
    func presentEnvironmentChanged(response: Event.EnvironmentChanged.Response)
}

extension EnvironmentsList {
    public typealias PresentationLogic = EnvironmentsListPresentationLogic
    
    @objc(EnvironmentsListPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = EnvironmentsList.Event
        public typealias Model = EnvironmentsList.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension EnvironmentsList.Presenter: EnvironmentsList.PresentationLogic {
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let cells = response.environments.map { (model) -> EnvironmentsList.EnvironmentCell.ViewModel in
            return EnvironmentsList.EnvironmentCell.ViewModel(
                title: model.rawValue,
                environment: model
            )
        }
        let viewModel = Event.ViewDidLoad.ViewModel(environments: cells)
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
    
    public func presentEnvironmentChanged(response: Event.EnvironmentChanged.Response) {
        let viewModel: Event.EnvironmentChanged.ViewModel
        switch response {
        case .changed:
            viewModel = .changed
            
        case .alreadyInThisEnvironment(let environment):
            let message = Localized(.application_is_already_configured_for_this_environment, replace: [
                .application_is_already_configured_for_this_environment_replace_environment: environment
                ])
            viewModel = .alreadyInThisEnvironment(message: message)
        }
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayEnvironmentChanged(viewModel: viewModel)
        }
    }
}
