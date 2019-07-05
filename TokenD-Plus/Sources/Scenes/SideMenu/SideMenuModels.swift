import UIKit

enum SideMenu {
    
    // MARK: - Typealiases
    
    // MARK: -
   
    enum Model {}
    enum Event {}
}

// MARK: - Models

extension SideMenu.Model {
    
    struct HeaderModel {
        let icon: UIImage?
        let title: String?
        let subTitle: String?
    }
    
    class SceneModel {
        
        var sections: [[MenuItem]]
        
        init(sections: [[MenuItem]]) {
            self.sections = sections
        }
    }
    
    class MenuItem {
        
        typealias OnSelected = (() -> Void)
        
        let iconImage: UIImage?
        var title: String
        
        var onSelected: OnSelected?
        
        // MARK: -
        
        init(
            iconImage: UIImage,
            title: String,
            onSelected: OnSelected?
            ) {
            
            self.iconImage = iconImage
            self.title = title
            
            self.onSelected = onSelected
        }
    }
    
    struct SectionModel {
        let items: [MenuItem]
        var isExpanded: Bool
    }
    
    struct SectionViewModel {
        let items: [CellViewAnyModel]
        var isExpanded: Bool
    }
    
    struct AccountItem {
        let name: String
        let image: UIImage
        let ownerAccountId: String
    }
}

// MARK: - Events

extension SideMenu.Event {
    typealias Model = SideMenu.Model
    
    enum ViewDidLoad {
        struct Request {
            
        }
        
        struct Response {
            let header: Model.HeaderModel
            let sections: [Model.SectionModel]
        }
        
        struct ViewModel {
            let header: Model.HeaderModel
            let sections: [Model.SectionViewModel]
        }
    }
    
    enum AccountChanged {
        
        struct Response {
            let ownerAccountId: String
            let companyName: String
        }
        typealias ViewModel = Response
    }
}
