import Foundation

public protocol CompaniesListPresentationLogic {
    typealias Event = CompaniesList.Event
    
    func presentSceneUpdated(response: Event.SceneUpdated.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
}

extension CompaniesList {
    public typealias PresentationLogic = CompaniesListPresentationLogic
    
    @objc(CompaniesListPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = CompaniesList.Event
        public typealias Model = CompaniesList.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
        
        // MARK: - Private properties
        
        private func getComapniesViewModels(
            models: [Model.Company]
            ) -> [CompanyCell.ViewModel] {
            
            return models.map({ (model) -> CompanyCell.ViewModel in
                let companyColor = TokenColoringProvider.shared.coloringForCode(model.name)
                return CompanyCell.ViewModel(
                    companyColor: companyColor,
                    companyImageUrl: model.imageUrl,
                    companyName: model.name,
                    accountId: model.accountId
                )
            })
        }
    }
}

extension CompaniesList.Presenter: CompaniesList.PresentationLogic {
    
    public func presentSceneUpdated(response: Event.SceneUpdated.Response) {
        let viewModel: Event.SceneUpdated.ViewModel
        switch response {
            
        case .companies(let comapnies):
            let companiesViewModels = self.getComapniesViewModels(models: comapnies)
            viewModel = .companies(companiesViewModels)
            
        case .error(let error):
            viewModel = .empty(error.localizedDescription)
            
        case .empty:
            viewModel = .empty(Localized(.there_is_not_any_company_where_you_are_a_client_yet))
        }
        self.presenterDispatch.display { displayLogic in
            displayLogic.displaySceneUpdated(viewModel: viewModel)
        }
    }
    
    public func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayLoadingStatusDidChange(viewModel: viewModel)
        }
    }
}
