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
        
        private let accountApiV3: AccountsApiV3
        private let originalAccountId: String
        
        // MARK: -
        
        init(
            accountApiV3: AccountsApiV3,
            originalAccountId: String
            ) {
            
            self.accountApiV3 = accountApiV3
            self.originalAccountId = originalAccountId
        }
        
        // MARK: - Private
        
        public func addCompany(
            businessAccountId: String,
            completion: @escaping (CompaniesListAddCompanyResult) -> Void
            ) {
            
            self.accountApiV3.addBusinesses(
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
