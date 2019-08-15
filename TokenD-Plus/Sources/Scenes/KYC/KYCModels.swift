import UIKit

public enum KYC {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension KYC.Model {
    
    public struct SceneModel {
        var fields: [Field]
    }
    
    public struct Field {
        let type: FieldType
        var value: String?
    }
    
    public enum FieldType {
        case name
        case surname
    }
    
    public enum ValidationError: Error {
        case emptyName
        case emptySurname
    }
    
    public enum KYCError: Error {
        case failedToEncodeData
        case failedToFormBlob
        case failedToBuildTransaction
        case other(Swift.Error)
    }
}

// MARK: - Events

extension KYC.Event {
    public typealias Model = KYC.Model
    
    // MARK: -
    
    public struct ViewDidLoad {
        public struct Request {}
        public struct Response {
            let fields: [Model.Field]
        }
        public struct ViewModel {
            let fields: [KYC.View.Field]
        }
    }
    
    public struct TextFieldValueDidChange {
        public struct Request {
            let fieldType: Model.FieldType
            let text: String?
        }
    }
    
    public struct Action {
        public struct Request {
            
        }
        public enum Response {
            case loading
            case loaded
            case success
            case validationError(Model.ValidationError)
            case failure(Model.KYCError)
        }
        public enum ViewModel {
            case loading
            case loaded
            case success(message: String)
            case validationError(String)
            case failure(message: String)
        }
    }
    
    public enum KYCApproved {
        public struct Response {}
        public typealias ViewModel = Response
    }
}
