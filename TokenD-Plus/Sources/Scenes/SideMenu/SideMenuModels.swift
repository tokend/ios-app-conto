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
    
    enum Identifier {
        case balances
        case companies
        case settings
    }
    
    class SceneModel {
        
        var sections: [[MenuItem]]
        
        init(sections: [[MenuItem]]) {
            self.sections = sections
        }
    }
    
    struct MenuItem {
        let iconImage: UIImage?
        let title: String
        let identifier: Identifier
    }
}

// MARK: - Events

extension SideMenu.Event {
    enum ViewDidLoad {
        struct Request {
            
        }
        
        struct Response {
            let header: SideMenu.Model.HeaderModel
            let sections: [[SideMenu.Model.MenuItem]]
        }
        
        struct ViewModel {
            let header: SideMenu.Model.HeaderModel
            let sections: [[SideMenuTableViewCell.Model]]
        }
    }
    
    typealias LanguageChanged = ViewDidLoad
}
