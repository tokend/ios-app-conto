import Foundation
import TokenDSDK

class VerifyEmailWorker {
    
    // MARK: - Public properties
    
    let keyServerApi: KeyServerApi
    let userDataManager: UserDataManagerProtocol
    let walletId: String
    let dispatchQueue: DispatchQueue = DispatchQueue(label: "verification-checker")
    
    // MARK: -
    
    init(
        keyServerApi: KeyServerApi,
        userDataManager: UserDataManagerProtocol,
        walletId: String
        ) {
        
        self.keyServerApi = keyServerApi
        self.userDataManager = userDataManager
        self.walletId = walletId
    }
    
    // MARK: - Public
    
    class func checkSavedWalletData(userDataManager: UserDataManagerProtocol) -> WalletDataSerializable? {
        guard let account = userDataManager.getMainAccount() else {
            return nil
        }
        return userDataManager.getWalletData(account: account)
    }
    
    class func canHandle(url: URL) -> Bool {
        return self.verifyEmailTokenFrom(url: url) != nil
    }
    
    class func verifyEmailTokenFrom(url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let pathComponents = components.path.components(separatedBy: "/r/")
        guard pathComponents.count == 2, let clientRedirectString = pathComponents.last else {
            return nil
        }
        
        guard let clientRedirect = ClientRedirectModel(string: clientRedirectString) else {
            return nil
        }
        
        switch clientRedirect.type {
            
        case .emailConfirmation(let meta):
            return meta.token
            
        case .unknown:
            return nil
        }
    }
}

extension VerifyEmailWorker: VerifyEmail.ResendWorker {
    func performResendRequest(
        completion: @escaping (VerifyEmailResendWorkerProtocol.Result) -> Void
        ) {
        
        self.keyServerApi.resendEmail(walletId: self.walletId, completion: { (result) in
            switch result {
                
            case .failure(let errors):
                completion(.failed(errors))
                
            case .success:
                completion(.succeded)
            }
        })
    }
}

extension VerifyEmailWorker: VerifyEmail.VerifyWorker {
    
    func checkVerificationState(
        completion: @escaping (VerifyEmailVerificationStateResult) -> Void
        ) {
        
        self.keyServerApi.requestWalletVerificationState(
            walletId: self.walletId,
            completion: { [weak self] (result) in
                switch result {
                case .verified:
                    completion(.verified)
                    
                case .unverified, .failure:
                    self?.dispatchQueue.asyncAfter(
                        deadline: .now() + .seconds(2),
                        execute: {
                            self?.checkVerificationState(completion: completion)
                    })
                }
        })
    }
    
    func performVerifyRequest(
        token: String,
        completion: @escaping (VerifyEmailVerifyWorkerProtocol.Result) -> Void
        ) {
        
        self.keyServerApi.verifyEmail(
            walletId: self.walletId,
            token: token,
            completion: { (result) in
                switch result {
                    
                case .failure(let error):
                    completion(.failed(error))
                    
                case .success:
                    completion(.succeded)
                }
        })
    }
    
    func verifyEmailTokenFrom(url: URL) -> String? {
        return VerifyEmailWorker.verifyEmailTokenFrom(url: url)
    }
}
