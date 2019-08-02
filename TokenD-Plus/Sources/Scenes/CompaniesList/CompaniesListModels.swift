import UIKit

public enum CompaniesList {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    public typealias QRCodeReaderCompletion = (_ result: Model.QRCodeReaderResult) -> Void
    public typealias AddCompanyCompletion = (Model.AddCompanyResult) -> Void
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension CompaniesList.Model {
    
    public struct SceneModel {
        var companies: [Company]
    }
    
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
        case companyNotFound
        case clientAlreadyHasBusiness(businessName: String)
        case invalidAccountId
    }
    
    public enum QRCodeReaderResult {
        case canceled
        case success(value: String, metadataType: String)
    }
    
    public enum AddCompanyResult {
        case success
        case error
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
            case error(String)
        }
    }
    
    public enum AddBusinessAction {
        public struct Request {
            let accountId: String
        }
        public enum Response {
            case success(company: Model.Company)
            case error(Swift.Error)
        }
        public enum ViewModel {
            case success(company: Model.Company)
            case error(String)
        }
    }
    
    public enum CompanyRecoignizeAction {
        public enum Response {
            case company(Model.Company)
            case error(Swift.Error)
        }
        public typealias ViewModel = Response
    }
    
    public enum LoadingStatusDidChange {
        public typealias Response = Model.LoadingStatus
        public typealias ViewModel = Response
    }
    
    public enum RefreshInitiated {
        public struct Request {}
    }
}
