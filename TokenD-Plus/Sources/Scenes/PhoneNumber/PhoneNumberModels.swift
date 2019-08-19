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
        var apiPhoneNumber: String?
        var number: String?
    }
    
    public enum Error: Swift.Error {
        case emptyNumber
        case numberIsNotValid
    }
    
    public struct ButtonAppearence {
        public let isEnabled: Bool
        public let title: String
    }
    
    public enum NumberState {
        case isNotSet
        case sameWithIdentity
        case updated
    }
}

// MARK: - Events

extension PhoneNumber.Event {
    public typealias Model = PhoneNumber.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public enum Request {}
    }
    
    public enum SceneUpdated {
        public struct Response {
            let number: String?
            let state: Model.NumberState
            let isUpdated: Bool
        }
        public struct ViewModel {
            let buttonAppearence: Model.ButtonAppearence
        }
    }
    
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
            case loading
            case loaded
        }
        
        public enum ViewModel {
            case success(String)
            case error(String)
            case loading
            case loaded
        }
    }
}
