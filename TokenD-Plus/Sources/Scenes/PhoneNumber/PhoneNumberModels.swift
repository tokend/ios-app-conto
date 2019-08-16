import UIKit

public enum PhoneNumber {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension PhoneNumber.Model {
    
    public struct SceneModel {
        var number: String?
    }
    
    public enum Error: Swift.Error {
        case emptyNumber
        case numberIsNotValid
    }
}

// MARK: - Events

extension PhoneNumber.Event {
    public typealias Model = PhoneNumber.Model
    
    // MARK: -
    
    public enum NumberEdited {
        public struct Request {
            let number: String?
        }
    }
    
    public enum SetNumberAction {
        public struct Request {}
        
        public enum Response {
            case success
            case error(Swift.Error)
        }
        
        public enum ViewModel {
            case success(String)
            case error(String)
        }
    }
}
