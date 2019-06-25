import TokenDSDK
import RxCocoa
import RxSwift

public protocol CompaniesListCompaniesFetcherProtocol {
    func observeCompanies() -> Observable<[CompaniesList.Model.Company]>
    func observeLoadingStatus() -> Observable<CompaniesList.Model.LoadingStatus>
    func observeErrors() -> Observable<Swift.Error>
}

extension CompaniesList {
    public typealias CompaniesFetcherProtocol = CompaniesListCompaniesFetcherProtocol
    
    public class CompaniesFetcher {
        
        // MARK: - Private properties
        
        private let companies: BehaviorRelay<[Model.Company]> = BehaviorRelay(value: [])
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let errors: PublishRelay<Swift.Error> = PublishRelay()
        
        // MARK: -
        
        init() {
            
        }
        
        // MARK: - Private
        
        private func loadCompanies() {
            
        }
    }
}

extension CompaniesList.CompaniesFetcher: CompaniesList.CompaniesFetcherProtocol {
    
    public func observeCompanies() -> Observable<[CompaniesList.Model.Company]> {
        self.loadCompanies()
        return self.companies.asObservable()
    }
    
    public func observeLoadingStatus() -> Observable<CompaniesList.Model.LoadingStatus> {
        return self.loadingStatus.asObservable()
    }
    
    public func observeErrors() -> Observable<Error> {
        return self.errors.asObservable()
    }
}


