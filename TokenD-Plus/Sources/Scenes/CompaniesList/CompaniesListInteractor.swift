import Foundation
import RxSwift

public protocol CompaniesListBusinessLogic {
    typealias Event = CompaniesList.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onRefreshInitiated(request: Event.RefreshInitiated.Request)
}

extension CompaniesList {
    public typealias BusinessLogic = CompaniesListBusinessLogic
    
    @objc(CompaniesListInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = CompaniesList.Event
        public typealias Model = CompaniesList.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let companiesFetcher: CompaniesFetcherProtocol
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            companiesFetcher: CompaniesFetcherProtocol
            ) {
            
            self.presenter = presenter
            self.companiesFetcher = companiesFetcher
        }
        
        // MARK: - Private properties
        
        private func observeCompanies() {
            self.companiesFetcher
                .observeCompanies()
                .subscribe(onNext: { [weak self] (companies) in
                    let response: Event.SceneUpdated.Response
                    response = companies.isEmpty ? .empty : .companies(companies)
                    self?.presenter.presentSceneUpdated(response: response)
                })
            .disposed(by: self.disposeBag)
        }
        
        private func observeLoadingStatus() {
            self.companiesFetcher
                .observeLoadingStatus()
                .subscribe(onNext: { [weak self] (status) in
                    self?.presenter.presentLoadingStatusDidChange(response: status)
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
        self.observeCompanies()
        self.observeLoadingStatus()
        self.observeErrors()
    }
    
    public func onRefreshInitiated(request: Event.RefreshInitiated.Request) {
        self.companiesFetcher.reloadCompanies()
    }
}
