import Foundation
import TokenDSDK
import TokenDWallet

public enum AccountVerificationCheckerResult {
    case verified
    case unverified
    case message(String)
    case error(Swift.Error)
}
public protocol AccountVerificationCheckerProtocol {
    func checkAccount()
}

public class AccountVerificationChecker {
    
    // MARK: - Private properties
    
    private let accountsApi: AccountsApiV3
    private let accountId: String
    
    private let showLoading: () -> Void
    private let hideLoading: () -> Void
    private let completion: (AccountVerificationCheckerResult) -> Void
    
    // MARK: -
    
    init(
        accountsApi: AccountsApiV3,
        accountId: String,
        showLoading: @escaping () -> Void,
        hideLoading: @escaping () -> Void,
        completion: @escaping (AccountVerificationCheckerResult) -> Void
        ) {
        
        self.accountsApi = accountsApi
        self.accountId = accountId
        self.showLoading = showLoading
        self.hideLoading = hideLoading
        self.completion = completion
    }
    
    // MARK: - Private
    
    private func fetchExistingForm() {
        self.accountsApi.requestChangeRoleRequests(
            filters: .with(.requestor(self.accountId)),
            include: ["request_details"],
            pagination: RequestPagination(.single(index: 0, limit: 10, order: .descending)),
            completion: { [weak self] (result) in
                switch result {
                    
                case .failure(let error):
                    self?.hideLoading()
                    self?.completion(.error(error))
                    
                case .success(let document):
                    guard let request = document.data?.first else {
                        self?.hideLoading()
                        self?.completion(.unverified)
                        return
                    }
                    
                    self?.handleReviewableRequest(request)
                }
        })
    }
    
    private func handleReviewableRequest(_ request: TokenDSDK.ReviewableRequestResource) {
        guard let requestDetailsType = request.requestDetails?.requestDetailsType else {
            self.hideLoading()
            return
        }
        
        switch requestDetailsType {
            
        case .changeRoleRequestDetails:
            self.hideLoading()
            switch request.stateValue {
                
            case .approved:
                self.completion(.verified)
                
            case .canceled:
                self.completion(.message(Localized(.kyc_canceled)))
                
            case .pending:
                self.completion(.message(Localized(.kyc_pending)))
                
            case .permanentlyRejected:
                self.completion(.message(Localized(.kyc_rejected)))
                
            case .rejected:
                self.completion(.message(Localized(.kyc_rejected)))
                
            case .unknown:
                self.completion(.message(Localized(.unknown)))
            }
            
        default:
            self.hideLoading()
        }
    }
}

extension AccountVerificationChecker: AccountVerificationCheckerProtocol {
    
    public func checkAccount() {
        self.showLoading()
        self.fetchExistingForm()
    }
}
