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
            let uaHardware = Model.Company.init(
                accountId: "GBA4EX43M25UPV4WIE6RRMQOFTWXZZRIPFAI5VPY6Z2ZVVXVWZ6NEOOB",
                name: "UA Hardware",
                imageUrl: URL(string: "https://google.com")!
            )
            
            let pubLolek = Model.Company.init(
                accountId: "GDLWLDE33BN7SG6V4P63V2HFA56JYRMODESBLR2JJ5F3ITNQDUVKS2JE",
                name: "Pub Lolek",
                imageUrl: URL(string: "https://google.com")!
            )
            self.companies.accept([uaHardware, pubLolek])
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


