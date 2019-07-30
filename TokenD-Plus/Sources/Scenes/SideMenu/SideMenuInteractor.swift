import Foundation

protocol SideMenuBusinessLogic {
    func onViewDidLoad(request: SideMenu.Event.ViewDidLoad.Request)
    func onLanguageChanged(request: SideMenu.Event.LanguageChanged.Request)
}

extension SideMenu {
    typealias BusinessLogic = SideMenuBusinessLogic
    
    class Interactor {
        
        private let presenter: PresentationLogic
        
        private let headerModel: Model.HeaderModel
        private let sceneModel: Model.SceneModel
        
        init(
            presenter: PresentationLogic,
            headerModel: Model.HeaderModel,
            sceneModel: Model.SceneModel
            ) {
            self.presenter = presenter
            self.headerModel = headerModel
            self.sceneModel = sceneModel
        }
        
        private func getSections() -> [[Model.MenuItem]] {
            let sections = [
                [
                    SideMenu.Model.MenuItem(
                        iconImage: Assets.amount.image,
                        title: Localized(.balances),
                        identifier: .balances
                    ),
                    SideMenu.Model.MenuItem(
                        iconImage: Assets.settingsIcon.image,
                        title: Localized(.settings),
                        identifier: .settings
                    ),
                    SideMenu.Model.MenuItem(
                        iconImage: Assets.companies.image,
                        title: Localized(.companies),
                        identifier: .companies
                    )
                ],
            ]
            
            return sections
        }
    }
}

extension SideMenu.Interactor: SideMenu.BusinessLogic {
    
    func onViewDidLoad(request: SideMenu.Event.ViewDidLoad.Request) {
        self.sceneModel.sections = getSections()
        let response = SideMenu.Event.ViewDidLoad.Response(
            header: self.headerModel,
            sections: self.sceneModel.sections
        )
        self.presenter.presentViewDidLoad(response: response)
    }
    
    func onLanguageChanged(request: SideMenu.Event.LanguageChanged.Request) {
        self.sceneModel.sections = getSections()
        let response = SideMenu.Event.ViewDidLoad.Response(
            header: self.headerModel,
            sections: self.sceneModel.sections
        )
        self.presenter.presentViewDidLoad(response: response)
    }
}
