import Foundation

protocol SideMenuBusinessLogic {
    func onViewDidLoad(request: SideMenu.Event.ViewDidLoad.Request)
}

extension SideMenu {
    typealias BusinessLogic = SideMenuBusinessLogic
    
    class Interactor {
        typealias Model = SideMenu.Model
        typealias Event = SideMenu.Event
        
        private let presenter: PresentationLogic
        
        private let headerModel: Model.HeaderModel
        private let sceneModel: Model.SceneModel
        private let accountsProvider: AccountsProviderProtocol
        
        init(
            presenter: PresentationLogic,
            headerModel: Model.HeaderModel,
            sceneModel: Model.SceneModel,
            accountsProvider: AccountsProviderProtocol
            ) {
            
            self.presenter = presenter
            self.headerModel = headerModel
            self.sceneModel = sceneModel
            self.accountsProvider = accountsProvider
        }
    }
}

extension SideMenu.Interactor: SideMenu.BusinessLogic {
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        var menuSections = self.sceneModel.sections.map { (items) -> Model.SectionModel in
            return Model.SectionModel.init(items: items, isExpanded: true)
        }
        let headerModel = self.headerModel
        self.accountsProvider.getAccountItems(completion: { [weak self] (accounts) in
            let accountMenuItems = accounts.map({ (account) -> Model.MenuItem in
                return Model.MenuItem(
                    iconImage: account.image,
                    title: account.name,
                    onSelected: {
                        let response = Event.AccountChanged.Response(
                            ownerAccountId: account.ownerAccountId,
                            companyName: account.name
                        )
                        self?.presenter.presentAccountChanged(response: response)
                })
            })
            let accountSection = Model.SectionModel(
                items: accountMenuItems,
                isExpanded: false
            )
            menuSections.insert(accountSection, at: 0)
            let response = Event.ViewDidLoad.Response(
                header: headerModel,
                sections: menuSections
            )
            self?.presenter.presentViewDidLoad(response: response)
        })
    }
}
