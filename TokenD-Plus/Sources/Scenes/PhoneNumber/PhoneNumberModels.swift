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
}
