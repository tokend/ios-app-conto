import Foundation

public protocol AddCompanyPresentationLogic {
    typealias Event = AddCompany.Event
    
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
    func presentAddCompanyAction(response: Event.AddCompanyAction.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
}

extension AddCompany {
    public typealias PresentationLogic = AddCompanyPresentationLogic
    
    @objc(AddCompanyPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = AddCompany.Event
        public typealias Model = AddCompany.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension AddCompany.Presenter: AddCompany.PresentationLogic {
    
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let logoAppearance: Model.LogoAppearance
        if let url = response.company.logo {
            logoAppearance = .logo(url: url)
        } else {
            logoAppearance = .abbreviation(
                text: response.company.name.first?.description ?? Character("D").description
            )
        }
        let companyViewModel = Model.CompanyViewModel(
            name: response.company.name,
            logoAppearance: logoAppearance
        )
        let viewModel = Event.ViewDidLoad.ViewModel(company: companyViewModel)
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
    
    public func presentAddCompanyAction(response: Event.AddCompanyAction.Response) {
        let viewModel: Event.AddCompanyAction.ViewModel
        switch response {
            
        case .error(let error):
            viewModel = .error(error.localizedDescription)
            
        case .success:
            viewModel = .success(Localized(.the_company_has_been_successfully_added))
        }
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayAddCompanyAction(viewModel: viewModel)
        }
    }
    
    public func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayLoadingStatusDidChange(viewModel: viewModel)
        }
    }
}
