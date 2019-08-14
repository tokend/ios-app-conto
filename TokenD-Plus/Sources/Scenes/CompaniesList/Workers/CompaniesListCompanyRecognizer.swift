import Foundation
import TokenDSDK

public enum CompaniesListRecognizeCompanyResult {
    case success(CompaniesList.Model.Company)
    case failure(Swift.Error)
}
public protocol CompaniesListCompanyRecognizerProtocol {
    func recognizeCompany(
        accountId: String,
        completion: @escaping (CompaniesListRecognizeCompanyResult) -> Void
    )
}

extension CompaniesList {
    public typealias CompanyRecognizerProtocol = CompaniesListCompanyRecognizerProtocol
    
    public class CompanyRecognizer {
        
        // MARK: - Private properties
        
        private let accountsApi: AccountsApiV3
        private let apiConfigurationModel: APIConfigurationModel
        private let companyIsNotFound: String = "404"
        private let defaultQuoteAsset: String = "UAH"
        
        // MARK: -
        
        init(
            accountsApi: AccountsApiV3,
            apiConfigurationModel: APIConfigurationModel
            ) {
            
            self.accountsApi = accountsApi
            self.apiConfigurationModel = apiConfigurationModel
        }
        
        // MARK: - Private
        
        private func handleCompany(
            resource: BusinessResource,
            completion: @escaping (CompaniesListRecognizeCompanyResult) -> Void
            ) {
            
            var imageUrl: URL?
            
            if let logoKey = resource.logoDetails?.key,
                !logoKey.isEmpty {
                    let logoUrl = self.apiConfigurationModel.storageEndpoint/logoKey
                    imageUrl = URL(string: logoUrl)
            }
            
            let conversionAsset = resource.statsQuoteAsset.isEmpty ?
            self.defaultQuoteAsset : resource.statsQuoteAsset
            let company = Model.Company(
                accountId: resource.accountId,
                name: resource.name,
                conversionAsset: conversionAsset,
                imageUrl: imageUrl
            )
            completion(.success(company))
        }
    }
}

extension CompaniesList.CompanyRecognizer: CompaniesList.CompanyRecognizerProtocol {
    
    public func recognizeCompany(
        accountId: String,
        completion: @escaping (CompaniesListRecognizeCompanyResult) -> Void
        ) {
        
        self.accountsApi
            .requestBusiness(
                accountId: accountId,
                completion: { [weak self] (result) in
                    switch result {
                    case .failure(let error):
                        if error.contains(status: self?.companyIsNotFound ?? "") {
                            completion(.failure(CompaniesList.Model.Error.companyNotFound))
                        }
                        completion(.failure(error))
                        
                    case .success(let document):
                        guard let data = document.data else {
                            completion(.failure(CompaniesList.Model.Error.companyNotFound))
                            return
                        }
                        self?.handleCompany(
                            resource: data,
                            completion: completion
                        )
                    }
                })
    }
}
