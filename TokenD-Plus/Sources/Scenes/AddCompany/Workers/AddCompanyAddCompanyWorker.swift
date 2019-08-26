import Foundation
import TokenDSDK

public enum AddCompanyResult {
    case success
    case failure(Swift.Error)
}
public protocol AddCompanyAddCompanyWorkerProtocol {
    func addCompany(
        businessAccountId: String,
        completion: @escaping (CompaniesListAddCompanyResult) -> Void
    )
}

extension AddCompany {
    public typealias AddCompanyWorkerProtocol = AddCompanyAddCompanyWorkerProtocol
    
    public class AddCompanyWorker: AddCompanyWorkerProtocol {
        
        // MARK: - Private properties
        
        private let integrationsApi: IntegrationsApiV3
        private let originalAccountId: String
        
        // MARK: -
        
        init(
            integrationsApi: IntegrationsApiV3,
            originalAccountId: String
            ) {
            
            self.integrationsApi = integrationsApi
            self.originalAccountId = originalAccountId
        }
        
        // MARK: - Private
        
        public func addCompany(
            businessAccountId: String,
            completion: @escaping (CompaniesListAddCompanyResult) -> Void
            ) {
            
            self.integrationsApi.addBusinesses(
                clientAccountId: self.originalAccountId,
                businessAccountId: businessAccountId,
                completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success:
                        completion(.success)
                    }
            })
        }
    }
}
