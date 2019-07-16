import UIKit

public enum FacilitiesList {
    
    // MARK: - Typealiases
    
    public typealias Identifier = String
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension FacilitiesList.Model {
    
    public struct FacilityItem {
        let name: String
        let icon: UIImage
        let type: FacilityType
        
        public enum FacilityType {
            case acceptRedeem
            case companies
            case settings
            case redeem
        }
    }
    
    public struct SectionModel {
        let title: String
        let items: [FacilityItem]
    }
    
    public struct SectionViewModel {
        let title: String
        let items: [FacilitiesList.FacilityCell.ViewModel]
    }
    
    public struct SceneModel {
        let originalAccountId: String
        let ownerAccountId: String
    }
}

// MARK: - Events

extension FacilitiesList.Event {
    public typealias Model = FacilitiesList.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let sections: [Model.SectionModel]
        }
        public struct ViewModel {
            let sections: [Model.SectionViewModel]
        }
    }
}
