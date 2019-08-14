import UIKit

public enum EnvironmentsList {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension EnvironmentsList.Model {
    public typealias Environment = APIConfigurationModel.Environment
}

// MARK: - Events

extension EnvironmentsList.Event {
    public typealias Model = EnvironmentsList.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let environments: [Model.Environment]
        }
        public struct ViewModel {
            let environments: [EnvironmentsList.EnvironmentCell.ViewModel]
        }
    }
    
    public struct EnvironmentChanged {
        public struct Request {
            let environment: Model.Environment
        }
        public enum Response {
            case changed
            case alreadyInThisEnvironment(environment: String)
        }
        public enum ViewModel {
            case changed
            case alreadyInThisEnvironment(message: String)
        }
    }
}
