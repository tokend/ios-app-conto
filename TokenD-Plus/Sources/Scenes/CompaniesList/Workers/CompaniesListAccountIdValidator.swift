import Foundation
import TokenDSDK
import TokenDWallet

public protocol CompaniesListAccountIdValidatorProtocol {
    func isValid(accountId: String) -> Bool
}

extension CompaniesList {
    public typealias AccountIdValidatorProtocol = CompaniesListAccountIdValidatorProtocol
    
    public class AccountIdValidator: AccountIdValidatorProtocol {
        
        // MARK: - AccountIdValidatorProtocol
        
        public func isValid(accountId: String) -> Bool {
            return Base32Check.isValid(expectedVersion: .accountIdEd25519, encoded: accountId)
        }
    }
}
