import UIKit

public enum CompaniesList {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension CompaniesList.Model {
    
    public struct Company {
        let accountId: String
        let name: String
        let imageUrl: URL?
    }
    
    public enum LoadingStatus {
        case loaded
        case loading
    }
    
    public enum Error: Swift.Error {
        case companiesNotFound
    }
}

// MARK: - Events

extension CompaniesList.Event {
    public typealias Model = CompaniesList.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
    }
    
    public enum SceneUpdated {
        public enum Response {
            case companies([Model.Company])
            case error(Swift.Error)
            case empty
        }
        
        public enum ViewModel {
            case companies([CompaniesList.CompanyCell.ViewModel])
            case empty(String)
        }
    }
    
    public enum LoadingStatusDidChange {
        public typealias Response = Model.LoadingStatus
        public typealias ViewModel = Response
    }
}
