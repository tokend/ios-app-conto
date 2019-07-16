import UIKit

public enum TabBar {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension TabBar.Model {
    
    public typealias TabIdentifier = String
    public typealias ActionIdentifier = String
    
    public struct SceneModel {
        var tabs: [TabItem]
        var selectedTab: TabItem?
        var selectedTabIdentifier: TabIdentifier?
    }
    
    public struct TabItem {
        let title: String
        let image: UIImage
        let actions: [ActionModel]
        let identifier: TabIdentifier
        let isSelectable: Bool
        
        init(
            title: String,
            image: UIImage,
            actions: [ActionModel] = [],
            identifier: TabIdentifier,
            isSelectable: Bool
            ) {
            
            self.title = title
            self.image = image
            self.actions = actions
            self.identifier = identifier
            self.isSelectable = isSelectable
        }
    }
    
    public struct ActionModel {
        let title: String
        let icon: UIImage
        let actionIdentifier: ActionIdentifier
    }
}

// MARK: - Events

extension TabBar.Event {
    public typealias Model = TabBar.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let tabs: [Model.TabItem]
            let selectedTab: Model.TabItem?
        }
        public typealias ViewModel = Response
    }
    
    public enum TabWasSelected {
        public struct Request {
            let identifier: Model.TabIdentifier
        }
        
        public struct Response {
            let item: Model.TabItem
        }
        public typealias ViewModel = Response
    }
    
    public enum Action {
        public struct Response {
            let tabIdentifier: Model.TabIdentifier
        }
        public typealias ViewModel = Response
    }
    
    public enum ShowActionsList {
        public struct Response {
            let tabIdentifier: String
            let actions: [Model.ActionModel]
        }
        public typealias ViewModel = Response
    }
}
