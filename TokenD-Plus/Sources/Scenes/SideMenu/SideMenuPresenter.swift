import Foundation

protocol SideMenuPresentationLogic {
    func presentViewDidLoad(response: SideMenu.Event.ViewDidLoad.Response)
    func presentAccountChanged(response: SideMenu.Event.AccountChanged.Response)
}

extension SideMenu {
    typealias PresentationLogic = SideMenuPresentationLogic
    typealias CellModel = SideMenuTableViewCell.Model
    
    struct Presenter {
        typealias Model = SideMenu.Model
        typealias Event = SideMenu.Event
        
        private let presenterDispatch: PresenterDispatch
        
        init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
        
        // MARK: - Private
        
        private func getCellModelSections(_ sections: [Model.SectionModel]) -> [Model.SectionViewModel] {
            let sections = sections.map { (section) -> Model.SectionViewModel in
                let cells = section.items.map({ (menuItem) -> CellModel in
                    let cellModel = CellModel(
                        icon: menuItem.iconImage,
                        title: menuItem.title,
                        onClick: menuItem.onSelected
                    )
                    
                    return cellModel
                })
                return Model.SectionViewModel(
                    items: cells,
                    isExpanded: section.isExpanded
                )
            }
            return sections
        }
    }
}

extension SideMenu.Presenter: SideMenu.PresentationLogic {
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let sections = self.getCellModelSections(response.sections)
        let viewModel = SideMenu.Event.ViewDidLoad.ViewModel(
            header: response.header,
            sections: sections
        )
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
    
    func presentAccountChanged(response: SideMenu.Event.AccountChanged.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayAccountChanged(viewModel: viewModel)
        }
    }
}
