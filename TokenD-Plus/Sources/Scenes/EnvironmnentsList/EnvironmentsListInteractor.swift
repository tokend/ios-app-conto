import Foundation

public protocol EnvironmentsListBusinessLogic {
    typealias Event = EnvironmentsList.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onEnvironmentChanged(request: Event.EnvironmentChanged.Request)
}

extension EnvironmentsList {
    public typealias BusinessLogic = EnvironmentsListBusinessLogic
    
    @objc(EnvironmentsListInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = EnvironmentsList.Event
        public typealias Model = EnvironmentsList.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let changeEnvironmentWorker: ChangeEnvironmentWorkerProtocol
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            changeEnvironmentWorker: ChangeEnvironmentWorkerProtocol
            ) {
            
            self.presenter = presenter
            self.changeEnvironmentWorker = changeEnvironmentWorker
        }
    }
}

extension EnvironmentsList.Interactor: EnvironmentsList.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        let cells: [Model.Environment] = [
            .production,
            .demo
        ]
        let response = Event.ViewDidLoad.Response(environments: cells)
        self.presenter.presentViewDidLoad(response: response)
    }
    
    public func onEnvironmentChanged(request: Event.EnvironmentChanged.Request) {
        self.changeEnvironmentWorker
            .changeEnvironment(
                environment: request.environment,
                completion: { [weak self] (result) in
                    let response: Event.EnvironmentChanged.Response
                    switch result {
                        
                    case .alreadyInThisEnvironment(let environment):
                        response = .alreadyInThisEnvironment(environment: environment)
                        
                    case .changed:
                        response = .changed
                    }
                    self?.presenter.presentEnvironmentChanged(response: response)
                })
    }
}
