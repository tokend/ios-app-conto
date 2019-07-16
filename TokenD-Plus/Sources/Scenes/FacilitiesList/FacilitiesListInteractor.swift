import Foundation

public protocol FacilitiesListBusinessLogic {
    typealias Event = FacilitiesList.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
}

extension FacilitiesList {
    public typealias BusinessLogic = FacilitiesListBusinessLogic
    
    @objc(FacilitiesListInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = FacilitiesList.Event
        public typealias Model = FacilitiesList.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let sceneModel: Model.SceneModel
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            sceneModel: Model.SceneModel
            ) {
            
            self.presenter = presenter
            self.sceneModel = sceneModel
        }
        
        // MARK: - Private
        
        private func getSections() -> [Model.SectionModel] {
            var sections: [Model.SectionModel] = []
            
            var redeemItems: [Model.FacilityItem] = []
            let redeemFacility = Model.FacilityItem(
                name: Localized(.create_redeem),
                icon: Assets.redeem.image,
                type: .redeem
            )
            redeemItems.append(redeemFacility)
            if self.sceneModel.originalAccountId == self.sceneModel.ownerAccountId {
                let acceptRedeemFacility = Model.FacilityItem(
                    name: Localized(.accept_redemption),
                    icon: Assets.scanQrIcon.image,
                    type: .acceptRedeem
                )
                redeemItems.append(acceptRedeemFacility)
            }
            let redeemSection = Model.SectionModel.init(
                title: Localized(.redeem),
                items: redeemItems
            )
            sections.append(redeemSection)
            
            let settingsFacility = Model.FacilityItem(
                name: Localized(.settings),
                icon: Assets.settingsIcon.image,
                type: .settings
            )
            let companiesFacility = Model.FacilityItem(
                name: Localized(.companies),
                icon: Assets.companies.image,
                type: .companies
            )
            let settingsSection = Model.SectionModel(
                title: "",
                items: [settingsFacility, companiesFacility]
            )
            sections.append(settingsSection)
            
            return sections
        }
    }
}

extension FacilitiesList.Interactor: FacilitiesList.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        let sections = self.getSections()
        let response = Event.ViewDidLoad.Response(sections: sections)
        self.presenter.presentViewDidLoad(response: response)
    }
}
