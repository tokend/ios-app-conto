import UIKit
import LocalAuthentication
import RxSwift
import TokenDSDK

class LocalAuthFlowController: BaseFlowController {
    
    // MARK: - Public properties
    
    let account: String
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol = NavigationController()
    private let userDataManager: UserDataManagerProtocol
    private let keychainManager: KeychainManagerProtocol
    private let onAuthorized: () -> Void
    private let onRecoverySucceeded: () -> Void
    private let onSignOut: () -> Void
    private let onKYCFailed: () -> Void
    
    private var kycChecker: AccountVerificationCheckerProtocol?
    
    private let disposeBag = DisposeBag()
    
    // MARK: -
    
    init(
        account: String,
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        rootNavigation: RootNavigationProtocol,
        userDataManager: UserDataManagerProtocol,
        keychainManager: KeychainManagerProtocol,
        onAuthorized: @escaping () -> Void,
        onRecoverySucceeded: @escaping () -> Void,
        onSignOut: @escaping () -> Void,
        onKYCFailed: @escaping () -> Void
        ) {
        
        self.account = account
        self.userDataManager = userDataManager
        self.keychainManager = keychainManager
        self.onAuthorized = onAuthorized
        self.onRecoverySucceeded = onRecoverySucceeded
        self.onSignOut = onSignOut
        self.onKYCFailed = onKYCFailed
        
        super.init(
            appController: appController,
            flowControllerStack: flowControllerStack,
            rootNavigation: rootNavigation
        )
    }
    
    // MARK: - Public
    
    func run(showRootScreen: ((_ vc: UIViewController) -> Void)?) {
        let vc: UIViewController
        
        let isBiometricsAuthEnabled = self.flowControllerStack.settingsManager.biometricsAuthEnabled
        let isDeviceCapable = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        if isBiometricsAuthEnabled && isDeviceCapable {
            self.navigationController.setNavigationBarHidden(true, animated: false)
            vc = self.setupBiometricsAuthScreen()
        } else {
            vc = self.setupPasswordAuthScreen()
        }
        
        self.navigationController.setViewControllers([vc], animated: false)
        
        if let showRoot = showRootScreen {
            showRoot(self.navigationController.getViewController())
        } else {
            self.rootNavigation.setRootContent(self.navigationController, transition: .fade, animated: false)
        }
    }
    
    // MARK: - Private
    
    private func setupBiometricsAuthScreen() -> UIViewController {
        let vc = BiometricsAuth.ViewController()
        
        let authWorker = BiometricsAuth.BiometricsAuthWorker(
            keychainManager: self.keychainManager
        )
        
        let routing = BiometricsAuth.Routing(
            onAuthSucceeded: { [weak self] account in
                self?.checkKYC(account: account)
            },
            onAuthFailed: { [weak self] in
                self?.showPasswordAuthScreenFromBiometricsAuth()
            },
            onUserCancelled: { [weak self] in
                self?.showPasswordAuthScreenFromBiometricsAuth()
            },
            onUserFallback: { [weak self] in
                self?.showPasswordAuthScreenFromBiometricsAuth()
        })
        
        BiometricsAuth.Configurator.configure(
            viewController: vc,
            authWorker: authWorker,
            routing: routing
        )
        
        let repeatButton = UIBarButtonItem(
            title: Localized(.repeat_title),
            style: .plain,
            target: nil,
            action: nil
        )
        repeatButton.rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController.setNavigationBarHidden(true, animated: true)
                self?.navigationController.popViewController(true)
            })
            .disposed(by: self.disposeBag)
        
        vc.navigationItem.backBarButtonItem = repeatButton
        
        return vc
    }
    
    private func showPasswordAuthScreenFromBiometricsAuth() {
        let vc = self.setupPasswordAuthScreen()
        
        self.navigationController.setNavigationBarHidden(false, animated: true)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupPasswordAuthScreen() -> UIViewController {
        let vc = RegisterScene.ViewController()
        
        let sceneModel = RegisterScene.Model.SceneModel.signInWithEmail(
            self.account,
            state: .localAuth
        )
        
        let localAuthWorker = RegisterScene.LocalSignInWorker(
            settingsManager: self.flowControllerStack.settingsManager,
            userDataManager: self.userDataManager,
            keychainManager: self.keychainManager
        )
        
        let passwordValidator = PasswordValidator()
        
        let routing = RegisterScene.Routing(
            showProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            },
            showErrorMessage: { [weak self] (errorMessage, completion) in
                self?.navigationController.showErrorMessage(errorMessage, completion: completion)
            },
            onSuccessfulLogin: { [weak self] (account) in
                self?.checkKYC(account: account)
            },
            onUnverifiedEmail: { _ in },
            onPresentQRCodeReader: { _ in},
            onSuccessfulSignUp: { _ in },
            onRecovery: { [weak self] in
                self?.showRecoveryScreen()
            },
            onAuthenticatorSignIn: {},
            showDialogAlert: { [weak self] (title, message, options, onSelected, onCanceled) in
                guard let present = self?.navigationController.getPresentViewControllerClosure() else {
                    return
                }
                
                self?.showDialog(
                    title: title,
                    message: message,
                    style: .alert,
                    options: options,
                    onSelected: onSelected,
                    onCanceled: onCanceled,
                    presentViewController: present
                )
            },
            onSignedOut: { [weak self] in
                self?.onSignOut()
            },
            onShowTerms: { _ in },
            onEnvironmentChanged: {}
        )
        
        RegisterScene.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            registerWorker: localAuthWorker,
            passwordValidator: passwordValidator,
            routing: routing
        )
        
        vc.navigationItem.title = Localized(.conto)
        
        return vc
    }
    
    private func showRecoveryScreen() {
        let vc = self.setupRecoveryScreen(onSuccess: { [weak self] in
            guard let present = self?.navigationController.getPresentViewControllerClosure() else {
                return
            }
            self?.showSuccessMessage(
                title: Localized(.success),
                message: Localized(.account_has_been_successfully_recovered),
                completion: {
                    self?.onRecoverySucceeded()
            },
                presentViewController: present
            )
        })
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func checkKYC(account: String) {
        guard let walletData = VerifyEmailWorker.checkSavedWalletData(userDataManager: self.userDataManager)
            else {
                return
        }
        self.kycChecker = AccountVerificationChecker(
            accountsApi: self.flowControllerStack.apiV3.accountsApi,
            accountId: walletData.accountId,
            showLoading: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideLoading: { [weak self] in
                self?.navigationController.hideProgress()
            },
            completion: { [weak self] result in
                switch result {
                    
                case .error(let error):
                    self?.navigationController.showErrorMessage(
                        error.localizedDescription,
                        completion: { [weak self] in
                            self?.onKYCFailed()
                        }
                    )
                    
                case .message(let message):
                    guard let presenter = self?.navigationController.getPresentViewControllerClosure() else {
                        return
                    }
                    self?.showSuccessMessage(
                        title: "",
                        message: message,
                        completion: { [weak self] in
                            self?.onKYCFailed()
                        },
                        presentViewController: presenter
                    )
                    
                case .unverified:
                    self?.showKYCScene(
                        account: account,
                        accountId: walletData.accountId
                    )
                    
                case .verified:
                    self?.onAuthorized()
                }
        })
        self.kycChecker?.checkAccount()
    }
    
    private func showKYCScene(account: String, accountId: String) {
        let vc = self.setupKYCScene(account: account, accountId: accountId)
        
        vc.navigationItem.title = Localized(.kyc)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupKYCScene(account: String, accountId: String) -> UIViewController {
        let vc = KYC.ViewController()
        guard let keyChainDataProvider = KeychainDataProvider(
            account: account,
            keychainManager: self.keychainManager
            ) else {
                self.onKYCFailed()
                return UIViewController()
        }
        let transactionSender = TransactionSender(
            api: self.flowControllerStack.api.transactionsApi,
            keychainDataProvider: keyChainDataProvider
        )
        let kycFormSender = KYC.KYCFormSender(
            accountsApi: self.flowControllerStack.api.accountsApi,
            accountsApiV3: self.flowControllerStack.apiV3.accountsApi,
            keyValueApi: self.flowControllerStack.apiV3.keyValuesApi,
            transactionSender: transactionSender,
            networkFetcher: self.flowControllerStack.networkInfoFetcher,
            originalAccountId: accountId
        )
        
        let kycVerificationChecker = KYC.VerificationChecker(
            accountsApi: self.flowControllerStack.apiV3.accountsApi,
            accountId: accountId
        )
        
        let routing = KYC.Routing(
            showLoading: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideLoading: { [weak self] in
                self?.navigationController.hideProgress()
            },
            showError: { [weak self] (message) in
                self?.navigationController.showErrorMessage(
                    message,
                    completion: { [weak self] in
                        self?.onKYCFailed()
                    }
                )
            },
            showMessage: { [weak self] (message) in
                guard let presenter = self?.navigationController.getPresentViewControllerClosure() else {
                    return
                }
                self?.showSuccessMessage(
                    title: Localized(.success),
                    message: message,
                    completion: nil,
                    presentViewController: presenter
                )
            }, showValidationError: { [weak self] (message) in
                self?.navigationController.showErrorMessage(
                    message,
                    completion: nil
                )
            }, showOnApproved: { [weak self] in
                self?.onAuthorized()
            }
        )
        
        KYC.Configurator.configure(
            viewController: vc,
            kycFormSender: kycFormSender,
            kycVerificationChecker: kycVerificationChecker,
            routing: routing
        )
        return vc
    }
    
    private func setupRecoveryScreen(onSuccess: @escaping () -> Void) -> UpdatePassword.ViewController {
        let vc = UpdatePassword.ViewController()
        
        let updateRequestBuilder = UpdatePasswordRequestBuilder(
            keyServerApi: self.flowControllerStack.keyServerApi
        )
        let passwordValidator = PasswordValidator()
        let submitPasswordHandler = UpdatePassword.RecoverWalletWorker(
            keyserverApi: self.flowControllerStack.keyServerApi,
            keychainManager: self.keychainManager,
            userDataManager: self.userDataManager,
            networkInfoFetcher: self.flowControllerStack.networkInfoFetcher,
            updateRequestBuilder: updateRequestBuilder,
            passwordValidator: passwordValidator
        )
        
        let fields = submitPasswordHandler.getExpectedFields()
        let sceneModel = UpdatePassword.Model.SceneModel(fields: fields)
        
        let routing = UpdatePassword.Routing(
            onShowProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            onHideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            },
            onShowErrorMessage: { [weak self] (errorMessage) in
                self?.navigationController.showErrorMessage(errorMessage, completion: nil)
            },
            onSubmitSucceeded: {
                onSuccess()
        })
        
        UpdatePassword.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            submitPasswordHandler: submitPasswordHandler,
            routing: routing
        )
        
        vc.navigationItem.title = Localized(.recovery)
        
        return vc
    }
}
