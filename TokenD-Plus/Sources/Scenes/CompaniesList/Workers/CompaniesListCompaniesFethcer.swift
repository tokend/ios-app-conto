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
        
        private let accountsApi: AccountsApiV3
        private let userDataProvider: UserDataProviderProtocol
        
        // MARK: -
        
        init(
            accountsApi: AccountsApiV3,
            userDataProvider: UserDataProviderProtocol
            ) {
            
            self.accountsApi = accountsApi
            self.userDataProvider = userDataProvider
        }
        
        // MARK: - Private
        
        private func loadCompanies() {
            let uaHardware = Model.Company.init(
                accountId: "GBA4EX43M25UPV4WIE6RRMQOFTWXZZRIPFAI5VPY6Z2ZVVXVWZ6NEOOB",
                name: "UA Hardware",
                imageUrl: URL(string: "https://pbs.twimg.com/profile_images/515290194946183168/zSW1LhVc.png")!
            )
            
            let pubLolek = Model.Company.init(
                accountId: "GDLWLDE33BN7SG6V4P63V2HFA56JYRMODESBLR2JJ5F3ITNQDUVKS2JE",
                name: "Pub Lolek",
                imageUrl: URL(string: "https://cmkt-image-prd.global.ssl.fastly.net/0.1.0/ps/2352370/910/607/m1/fpnw/wm0/beer-mug-dwg_prvw-.jpg?1488440459&s=525e7ba48e0a83ea6dcb09b4cae6440f")!
            )
            self.companies.accept([uaHardware, pubLolek])
        }
    }
    
    //    private func loadCompanies() {
    //        self.loadingStatus.accept(.loading)
    //        self.accountsApi.requestBusinesses(
    //            accountId: self.userDataProvider.walletData.accountId,
    //            completion: { [weak self] (result) in
    //        self.loadingStatus.accept(.loaded)
    //                switch result {
    //
    //                case .failure(let error):
    //                    self?.errors.accept(error)
    //
    //                case .success(let document):
    //                    guard let businesses = document.data else {
    //                        self?.errors.accept(Model.Error.companiesNotFound)
    //                        return
    //                    }
    //                    self?.convertToCompanies(businesses: businesses)
    //                }
    //            }
    //        )
    //    }
    //
    //    private func convertToCompanies(businesses: [BusinessResource]) {
    //        let companies = businesses.map { (resource) -> Model.Company in
    //            return Model.Company(
    //                accountId: resource.accountId,
    //                name: resource.name,
    //                imageUrl: URL(string: resource.logoLink)
    //            )
    //        }
    //        self.companies.accept(companies)
    //    }
    //}
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


