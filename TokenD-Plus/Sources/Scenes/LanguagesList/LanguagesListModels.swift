import UIKit

public enum LanguagesList {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension LanguagesList.Model {
    
    public struct Language {
        let name: String
        let code: String
    }
}

// MARK: - Events

extension LanguagesList.Event {
    public typealias Model = LanguagesList.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let languages: [Model.Language]
        }
        public struct ViewModel {
            let languages: [LanguagesList.LanguageCell.ViewModel]
        }
    }
    
    public struct LanguageChanged {
        public struct Request {
            let languageCode: String
        }
        public enum Response {
            case success
            case failure(Swift.Error)
        }
        public enum ViewModel {
            case success
            case failure(String)
        }
    }
}
