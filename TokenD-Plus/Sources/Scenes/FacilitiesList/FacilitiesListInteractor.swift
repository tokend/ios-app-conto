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
            
            let settingsFacility = Model.FacilityItem(
                name: Localized(.settings),
                icon: Assets.settingsIcon.image,
                type: .settings
            )
            let settingsSection = Model.SectionModel(
                title: "",
                items: [settingsFacility]
            )
            sections.append(settingsSection)
            
            let companiesFacility = Model.FacilityItem(
                name: Localized(.back_to_companies),
                icon: Assets.companies.image,
                type: .companies
            )
            let companiesSection = Model.SectionModel(
                title: "",
                items: [companiesFacility]
            )
            sections.append(companiesSection)
            
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
