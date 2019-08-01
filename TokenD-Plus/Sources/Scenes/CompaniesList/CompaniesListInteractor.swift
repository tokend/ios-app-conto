import Foundation
import RxSwift
import RxCocoa

public protocol CompaniesListBusinessLogic {
    typealias Event = CompaniesList.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onRefreshInitiated(request: Event.RefreshInitiated.Request)
    func onAddBusinessAction(request: Event.AddBusinessAction.Request)
}

extension CompaniesList {
    public typealias BusinessLogic = CompaniesListBusinessLogic
    
    @objc(CompaniesListInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = CompaniesList.Event
        public typealias Model = CompaniesList.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private var sceneModel: Model.SceneModel
        private let companiesFetcher: CompaniesFetcherProtocol
        private let companyRecognizer: CompanyRecognizerProtocol
        private let accountIdValidator: AccountIdValidatorProtocol
        
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            sceneModel: Model.SceneModel,
            companiesFetcher: CompaniesFetcherProtocol,
            companyRecognizer: CompanyRecognizerProtocol,
            accountIdValidator: AccountIdValidatorProtocol
            ) {
            
            self.presenter = presenter
            self.sceneModel = sceneModel
            self.companiesFetcher = companiesFetcher
            self.companyRecognizer = companyRecognizer
            self.accountIdValidator = accountIdValidator
        }
        
        // MARK: - Private properties
        
        private func observeLoadingStatus() {
            self.loadingStatus
                .subscribe(onNext: { [weak self] (status) in
                    self?.presenter.presentLoadingStatusDidChange(response: status)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func observeCompanies() {
            self.companiesFetcher
                .observeCompanies()
                .subscribe(onNext: { [weak self] (companies) in
                    self?.sceneModel.companies = companies
                    let response: Event.SceneUpdated.Response
                    response = companies.isEmpty ? .empty : .companies(companies)
                    self?.presenter.presentSceneUpdated(response: response)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func observeRepoLoadingStatus() {
            self.companiesFetcher
                .observeLoadingStatus()
                .subscribe(onNext: { [weak self] (status) in
                    self?.loadingStatus.accept(status)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func observeErrors() {
            self.companiesFetcher
                .observeErrors()
                .subscribe(onNext: { [weak self] (error) in
                    let response = Event.SceneUpdated.Response.error(error)
                    self?.presenter.presentSceneUpdated(response: response)
                })
                .disposed(by: self.disposeBag)
        }
    }
}

extension CompaniesList.Interactor: CompaniesList.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.observeLoadingStatus()
        self.observeCompanies()
        self.observeRepoLoadingStatus()
        self.observeErrors()
    }
    
    public func onRefreshInitiated(request: Event.RefreshInitiated.Request) {
        self.companiesFetcher.reloadCompanies()
    }
    
    public func onAddBusinessAction(request: Event.AddBusinessAction.Request) {
        self.loadingStatus.accept(.loading)
        guard self.accountIdValidator.isValid(accountId: request.accountId) else {
            self.loadingStatus.accept(.loaded)
            self.presenter.presentAddBusinessAction(
                response: .error(Model.Error.invalidAccountId)
            )
            return
        }
        
        let company = self.sceneModel.companies.first(where: { (company) -> Bool in
            return company.accountId == request.accountId
        })
        
        guard company == nil else {
            self.loadingStatus.accept(.loaded)
            self.presenter.presentAddBusinessAction(
                response: .error(Model.Error.clientAlreadyHasBusiness(businessName: company?.name ?? ""))
            )
            return
        }
        
        self.companyRecognizer.recognizeCompany(
            accountId: request.accountId,
            completion: { [weak self] (result) in
                self?.loadingStatus.accept(.loaded)
                let response: Event.AddBusinessAction.Response
                switch result {
                    
                case .failure(let error):
                    response = .error(error)
                    
                case .success(let company):
                    response = .success(company: company)
                }
                self?.presenter.presentAddBusinessAction(response: response)
        })
    }
}
