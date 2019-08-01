import UIKit

public enum AddCompany {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    public typealias AddAccountCompletion = (Model.AddCompanyResult) -> Void
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension AddCompany.Model {
    
    public struct SceneModel {
        let company: Company
    }
    
    public struct Company {
        let accountId: String
        let name: String
        let logo: URL?
    }
    
    public struct CompanyViewModel {
        let name: String
        let logoAppearance: LogoAppearance
    }
    
    public enum LogoAppearance {
        case abbreviation(text: String)
        case logo(url: URL)
    }
    
    public enum AddCompanyResult {
        case success(String)
        case error(String)
    }
    
    public enum LoadingStatus {
        case loading
        case loaded
    }
}

// MARK: - Events

extension AddCompany.Event {
    public typealias Model = AddCompany.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let company: Model.Company
        }
        public struct ViewModel {
            let company: Model.CompanyViewModel
        }
    }
    
    public enum AddCompanyAction {
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
    
    public enum LoadingStatusDidChange {
        public typealias Response = Model.LoadingStatus
        public typealias ViewModel = Model.LoadingStatus
    }
}
