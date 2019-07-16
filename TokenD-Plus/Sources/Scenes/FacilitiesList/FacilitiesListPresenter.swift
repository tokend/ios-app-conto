import Foundation

public protocol FacilitiesListPresentationLogic {
    typealias Event = FacilitiesList.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
}

extension FacilitiesList {
    public typealias PresentationLogic = FacilitiesListPresentationLogic
    
    @objc(FacilitiesListPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = FacilitiesList.Event
        public typealias Model = FacilitiesList.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
        
        
    }
}

extension FacilitiesList.Presenter: FacilitiesList.PresentationLogic {
    
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let sectionViewModels = response.sections.map { (section) -> Model.SectionViewModel in
            let itemViewModels = section.items.map({ (model) -> FacilitiesList.FacilityCell.ViewModel in
                return FacilitiesList.FacilityCell.ViewModel(
                    title: model.name,
                    icon: model.icon,
                    type: model.type
                )
            })
            return Model.SectionViewModel(
                title: section.title,
                items: itemViewModels
            )
        }
        let viewModel = Event.ViewDidLoad.ViewModel(sections: sectionViewModels)
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
}
