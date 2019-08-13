import Foundation

public protocol CompaniesListPresentationLogic {
    typealias Event = CompaniesList.Event
    
    func presentSceneUpdated(response: Event.SceneUpdated.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
    func presentAddBusinessAction(response: Event.AddBusinessAction.Response)
    func presentCompanyChosen(response: Event.CompanyChosen.Response)
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
                let firstCharacter = model.name.first ?? Character("D")
                let companyAbbreviation = "\(firstCharacter)".uppercased()
                return CompanyCell.ViewModel(
                    companyColor: companyColor,
                    companyImageUrl: model.imageUrl,
                    companyName: model.name,
                    companyAbbreviation: companyAbbreviation,
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
            viewModel = .error(error.localizedDescription)
            
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
    
    public func presentAddBusinessAction(response: Event.AddBusinessAction.Response) {
        let viewModel: Event.AddBusinessAction.ViewModel
        switch response {
            
        case .error(let error):
            viewModel = .error(error.localizedDescription)
            
        case .success(let company):
            viewModel = .success(company: company)
        }
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayAddBusinessAction(viewModel: viewModel)
        }
    }
    
    public func presentCompanyChosen(response: Event.CompanyChosen.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayCompanyChosen(viewModel: viewModel)
        }
    }
}

extension CompaniesList.Model.Error: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
            
        case .companyNotFound:
            return Localized(.failed_to_fetch_company)
            
        case .companiesNotFound:
            return Localized(.failed_to_fetch_companies)
            
        case .clientAlreadyHasBusiness(let businessName):
            return Localized(
                .you_are_already_client_of_the_business,
                replace: [
                    .you_are_already_client_of_the_business_replace_business_name: businessName
                ]
            )
            
        case .invalidAccountId:
            return Localized(.invalid_company_account_id)
        }
    }
}
