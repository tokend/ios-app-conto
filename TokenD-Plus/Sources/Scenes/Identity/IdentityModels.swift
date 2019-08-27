import UIKit

public enum Identity {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension Identity.Model {
    
    public struct SceneModel {
        let accountId: String
        var apiValue: String?
        var value: String?
        let sceneType: SceneType
    }
    
    public enum SceneType {
        case telegram
        case phoneNumber
    }
    
    public struct ButtonAppearence {
        public let isEnabled: Bool
        public let title: String
    }
    
    public enum ValueState {
        case isNotSet
        case sameWithIdentity
        case updated
    }
    
    public enum LoadingStatus {
        case loaded
        case loading
    }
    
    public struct ViewConfig {
        let hint: String
        let prefix: String
        let placeholder: String
        let keyboardType: UIKeyboardType
        let valueFormatter: ValueFormatter<String>
    }
}

// MARK: - Events

extension Identity.Event {
    public typealias Model = Identity.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
    }
    
    public enum SceneUpdated {
        public struct Response {
            let value: String?
            let state: Model.ValueState
            let sceneType: Model.SceneType
        }
        public struct ViewModel {
            let value: String?
            let buttonAppearence: Model.ButtonAppearence
        }
    }
    
    public enum ValueEdited {
        public struct Request {
            let value: String?
        }
    }
    
    public struct Action {
        public struct Request {}
    }
    
    public enum SetAction {
        public enum Response {
            case success(sceneType: Model.SceneType)
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
    
    public enum LoadingStatusDidChange {
        public typealias Response = Model.LoadingStatus
        public typealias ViewModel = Model.LoadingStatus
    }
    
    public enum Error {
        public struct Response {
            let error: Swift.Error
        }
        public struct ViewModel {
            let error: String
        }
    }
}

extension Identity.Event.SetAction {
    public enum SetNumberError: Swift.Error {
        case emptyNumber
        case numberIsNotValid
        case invalidCode
    }
}

extension Identity.Event.SetAction {
    public enum SetTelegramError: Swift.Error {
        case emptyUserName
        case invalidCode
    }
}
