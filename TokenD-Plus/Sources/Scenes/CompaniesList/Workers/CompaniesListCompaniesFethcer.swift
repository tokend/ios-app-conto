import TokenDSDK
import RxCocoa
import RxSwift

public protocol CompaniesListCompaniesFetcherProtocol {
    func observeCompanies() -> Observable<[CompaniesList.Model.Company]>
    func observeLoadingStatus() -> Observable<CompaniesList.Model.LoadingStatus>
    func observeErrors() -> Observable<Swift.Error>
    func reloadCompanies()
}

extension CompaniesList {
    public typealias CompaniesFetcherProtocol = CompaniesListCompaniesFetcherProtocol
    
    public class CompaniesFetcher {
        
        // MARK: - Private properties
        
        private let companies: BehaviorRelay<[Model.Company]> = BehaviorRelay(value: [])
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let errors: PublishRelay<Swift.Error> = PublishRelay()
        
        private let accountsApi: AccountsApiV3
        private let apiConfiguration: APIConfigurationModel
        private let userDataProvider: UserDataProviderProtocol
        
        // MARK: -
        
        init(
            accountsApi: AccountsApiV3,
            apiConfiguration: APIConfigurationModel,
            userDataProvider: UserDataProviderProtocol
            ) {
            
            self.accountsApi = accountsApi
            self.apiConfiguration = apiConfiguration
            self.userDataProvider = userDataProvider
        }
        
        // MARK: - Private
        
        private func loadCompanies() {
            self.loadingStatus.accept(.loading)
            self.accountsApi.requestBusinesses(
                accountId: self.userDataProvider.walletData.accountId,
                completion: { [weak self] (result) in
                    self?.loadingStatus.accept(.loaded)
                    switch result {
                        
                    case .failure(let error):
                        self?.errors.accept(error)
                        
                    case .success(let document):
                        guard let businesses = document.data else {
                            self?.errors.accept(Model.Error.companiesNotFound)
                            return
                        }
                        self?.convertToCompanies(businesses: businesses)
                    }
                }
            )
        }
        
        private func convertToCompanies(businesses: [BusinessResource]) {
            let companies = businesses.map { (resource) -> Model.Company in
                var imageUrl: URL?
                if let logoDetails = resource.logoDetails {
                    let logoPath = self.apiConfiguration.storageEndpoint/logoDetails.key
                    imageUrl = URL(string: logoPath)
                }
                return Model.Company(
                    accountId: resource.accountId,
                    name: resource.name,
                    imageUrl: imageUrl
                )
            }
            self.companies.accept(companies)
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
    
    public func reloadCompanies() {
        self.loadCompanies()
    }
}

extension BusinessResource {
    
    public struct Logo: Decodable {
        let key: String
    }
    
    var logoDetails: Logo? {
        guard let jsonData = self.logoJSON.data(using: .utf8) else {
            return nil
        }
        
        guard let logo = try? JSONDecoder().decode(
            Logo.self,
            from: jsonData
            ) else { return nil }
        
        return logo
    }
}

