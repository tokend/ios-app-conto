import UIKit
import TokenDSDK
import RxSwift

class CompaniesListFlowController: BaseSignedInFlowController {
    
    // MARK: - Public properties
    
    static let userActionsTimeout: TimeInterval = 15 * 60
    static let backgroundTimeout: TimeInterval = 15 * 60
    
    private(set) var isAuthorized: Bool = true
    private let shouldAddCompany: Bool
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol = NavigationController()
    
    private let addAccountWorker: AddCompany.AddCompanyWorker
    private let onSignOut: () -> Void
    private let onEnvironmentChanged: () -> Void
    private let onLocalAuthRecoverySucceeded: () -> Void
    
    private var localAuthFlow: LocalAuthFlowController?
    private var timeoutSubscribeToken: TimerUIApplication.SubscribeToken = TimerUIApplication.SubscribeTokenInvalid
    private var backgroundTimer: Timer?
    private var backgroundToken: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    private var showRootScreen: ((UIViewController) -> Void)?
    
    // MARK: -
    
    init(
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol,
        addAccountWorker: AddCompany.AddCompanyWorker,
        shouldAddCompany: Bool = false,
        onSignOut: @escaping (() -> Void),
        onEnvironmentChanged: @escaping (() -> Void),
        onLocalAuthRecoverySucceeded: @escaping () -> Void
        ) {
        
        self.addAccountWorker = addAccountWorker
        self.onSignOut = onSignOut
        self.onEnvironmentChanged = onEnvironmentChanged
        self.onLocalAuthRecoverySucceeded = onLocalAuthRecoverySucceeded
        self.shouldAddCompany = shouldAddCompany
        super.init(
            appController: appController,
            flowControllerStack: flowControllerStack,
            reposController: reposController,
            managersController: managersController,
            userDataProvider: userDataProvider,
            keychainDataProvider: keychainDataProvider,
            rootNavigation: rootNavigation
        )
        
        self.timeoutSubscribeToken = TimerUIApplication.subscribeForTimeoutNotification(handler: { [weak self] in
            self?.isAuthorized = false
            self?.stopUserActivityTimer()
            _ = self?.checkIsAuthorized()
        })
    }
    
    deinit {
        TimerUIApplication.unsubscribeFromTimeoutNotification(self.timeoutSubscribeToken)
        self.timeoutSubscribeToken = TimerUIApplication.SubscribeTokenInvalid
    }
    
    // MARK: - Override
    
    override func applicationDidEnterBackground() {
        guard self.localAuthFlow == nil else { return }
        
        self.startBackgroundTimer()
    }
    
    override func applicationWillEnterForeground() {
        guard self.localAuthFlow == nil else { return }
        
        self.stopBackgroundTimer()
    }
    
    override func applicationWillResignActive() {
        guard self.localAuthFlow == nil else { return }
        
        self.rootNavigation.showBackgroundCover()
    }
    
    override func applicationDidBecomeActive() {
        self.rootNavigation.hideBackgroundCover()
        
        if self.checkIsAuthorized() {
            self.currentFlowController?.applicationDidBecomeActive()
        }
    }
    
    // MARK: - Public
    
    public func run(showRootScreen: ((UIViewController) -> Void)?) {
        self.showRootScreen = showRootScreen
        if self.shouldAddCompany {
            self.addAccountWorker.addCompany(
                businessAccountId: "GB6RXMSM77D4PAJKAD3LWLZ2YTDB47P72VVU27QCDZ6O4FSHBECQYVCV",
                completion: { [weak self] (result) in
                    self?.showCompaniesScreen()
                    self?.startUserActivityTimer()
            })
        } else {
            self.showCompaniesScreen()
            self.startUserActivityTimer()
        }
    }
    
    // MARK: - Private
    
    private func showCompaniesScreen() {
        let vc = self.setupCompaniesScreen()
        
        vc.navigationItem.title = Localized(.companies)
        self.navigationController.setViewControllers([vc], animated: false)
        
        if let showRootScreen = self.showRootScreen {
            showRootScreen(self.navigationController.getViewController())
        } else {
            self.rootNavigation.setRootContent(
                self.navigationController,
                transition: .fade,
                animated: true
            )
        }
    }
    
    private func showHomeScreen() {
        let vc = self.setupCompaniesScreen()
        
        vc.navigationItem.title = Localized(.companies)
        self.navigationController.setViewControllers([vc], animated: false)
        
        self.rootNavigation.setRootContent(
            self.navigationController,
            transition: .fade,
            animated: true
        )
    }
    
    private func setupCompaniesScreen() -> UIViewController {
        let vc = CompaniesList.ViewController()
        
        let sceneModel = CompaniesList.Model.SceneModel(companies: [])
        let companiesFetcher = CompaniesList.CompaniesFetcher(
            integrationsApi: self.flowControllerStack.apiV3.integrationsApi,
            apiConfiguration: self.flowControllerStack.apiConfigurationModel,
            userDataProvider: self.userDataProvider
        )
        let companyRecognizer = CompaniesList.CompanyRecognizer(
            integrationsApi: self.flowControllerStack.apiV3.integrationsApi,
            apiConfigurationModel: self.flowControllerStack.apiConfigurationModel
        )
        let accountIdValidator = CompaniesList.AccountIdValidator()
        let routing = CompaniesList.Routing(
            showLoading: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideLoading: { [weak self] in
                self?.navigationController.hideProgress()
            }, showShadow: { [weak self] in
                self?.navigationController.showShadow()
            },
               hideShadow: { [weak self] in
                self?.navigationController.hideShadow()
            },
               onCompanyChosen: { [weak self] (company) in
                self?.flowControllerStack.settingsManager.businessOwnerAccountId = company.accountId
                self?.flowControllerStack.settingsManager.businessName = company.name
                self?.flowControllerStack.settingsManager.businessConversionAsset = company.conversionAsset
                self?.flowControllerStack.settingsManager.businessImageKey = company.imageUrl?.absoluteString
                self?.runCompanyFlow(company: company)
            },
               showError: { [weak self] (message) in
                self?.navigationController.showErrorMessage(
                    message,
                    completion: nil
                )
            }, showSuccessMessage: { [weak self] (message) in
                guard let present = self?.navigationController.getPresentViewControllerClosure() else {
                    return
                }
                self?.showSuccessMessage(
                    title: Localized(.success),
                    message: message,
                    completion: nil,
                    presentViewController: present
                )
            }, onPresentQRCodeReader: { [weak self] (completion) in
                self?.presentQRCodeReader(completion: completion)
            }, onAddCompany: { [weak self] (company,completion) in
                let addCompany = AddCompany.Model.Company(
                    accountId: company.accountId,
                    name: company.name,
                    logo: company.imageUrl
                )
                self?.showAddCompanyScene(
                    company: addCompany,
                    completion: completion
                )
        })
        CompaniesList.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            companiesFetcher: companiesFetcher,
            companyRecognizer: companyRecognizer,
            accountIdValidator: accountIdValidator,
            routing: routing
        )
        
        return vc
    }
    
    private func runCompanyFlow(company: CompaniesList.Model.Company) {
        let flow = CompanyFlowController(
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation,
            company: company,
            onSignOut: self.onSignOut,
            onEnvironmentChanged: self.onEnvironmentChanged,
            onLocalAuthRecoverySucceeded: { [weak self] in
                self?.onLocalAuthRecoverySucceeded()
        })
        self.currentFlowController = flow
        flow.run()
    }
    
    private func showAddCompanyScene(
        company: AddCompany.Model.Company,
        completion: @escaping (CompaniesList.AddCompanyCompletion)
        ) {
        
        let vc = self.setupAddCompanyScene(company: company, completion: completion)
        vc.navigationItem.title = Localized(.add_company)
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupAddCompanyScene(
        company: AddCompany.Model.Company,
        completion: @escaping (CompaniesList.AddCompanyCompletion)
        ) -> UIViewController {
        
        let vc = AddCompany.ViewController()
        let sceneModel = AddCompany.Model.SceneModel(company: company)
        let addCompanyWorker = AddCompany.AddCompanyWorker(
            integrationsApi: self.flowControllerStack.apiV3.integrationsApi,
            originalAccountId: self.userDataProvider.walletData.accountId
        )
        let routing = AddCompany.Routing(
            onAddActionResult: { [weak self] (result) in
                switch result {
                case .error(let error):
                    completion(.error)
                    self?.navigationController.showErrorMessage(
                        error,
                        completion: {
                            self?.navigationController.popViewController(true)
                    })
                    
                case .success(let message):
                    completion(.success)
                    guard let present = self?.navigationController.getPresentViewControllerClosure() else {
                        return
                    }
                    self?.showSuccessMessage(
                        title: Localized(.success),
                        message: message,
                        completion: {
                            self?.navigationController.popViewController(true)
                    },
                        presentViewController: present
                    )
                }
            },
            onCancel: { [weak self] in
                self?.navigationController.popViewController(true)
            },
            showLoading: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideLoading: { [weak self] in
                self?.navigationController.hideProgress()
        })
        
        AddCompany.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            addCompanyWorker: addCompanyWorker,
            routing: routing
        )
        return vc
    }
    
    // MARK: - Sign out
    
    private func initiateSignOut() {
        let alert = UIAlertController(
            title: Localized(.sign_out),
            message: Localized(.are_you_sure_you_want_to_sign_out),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: Localized(.sign_out_and_erase),
            style: .default,
            handler: { [weak self] _ in
                self?.performSignOut()
        }))
        
        alert.addAction(UIAlertAction(
            title: Localized(.cancel),
            style: .cancel,
            handler: nil
        ))
        
        self.navigationController.present(alert, animated: true, completion: nil)
    }
    
    private func performSignOut() {
        let signOutWorker = RegisterScene.LocalSignInWorker(
            settingsManager: self.flowControllerStack.settingsManager,
            userDataManager: self.managersController.userDataManager,
            keychainManager: self.managersController.keychainManager
        )
        
        signOutWorker.performSignOut(completion: { [weak self] in
            self?.onSignOut()
        })
    }
    
    private func presentQRCodeReader(completion: @escaping CompaniesList.QRCodeReaderCompletion) {
        self.runQRCodeReaderFlow(
            presentingViewController: self.navigationController.getViewController(),
            handler: { result in
                switch result {
                    
                case .canceled:
                    completion(.canceled)
                    
                case .success(let value, let metadataType):
                    completion(.success(value: value, metadataType: metadataType))
                }
        })
    }
    
    // MARK: - Timeout management
    
    private func startUserActivityTimer() {
        TimerUIApplication.startIdleTimer()
    }
    
    private func stopUserActivityTimer() {
        TimerUIApplication.stopIdleTimer()
    }
    
    private func startBackgroundTimer() {
        self.backgroundToken = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        self.backgroundTimer = Timer.scheduledTimer(
            withTimeInterval: CompaniesListFlowController.backgroundTimeout,
            repeats: false,
            block: { [weak self] _ in
                self?.isAuthorized = false
                self?.stopBackgroundTimer()
        })
    }
    
    private func stopBackgroundTimer() {
        self.backgroundTimer?.invalidate()
        self.backgroundTimer = nil
        UIApplication.shared.endBackgroundTask(self.backgroundToken)
        self.backgroundToken = UIBackgroundTaskIdentifier.invalid
    }
    
    private func checkIsAuthorized() -> Bool {
        if !self.isAuthorized && UIApplication.shared.applicationState == .active {
            self.runLocalAuthByTimeout()
            return false
        }
        
        return true
    }
    
    private func runLocalAuthByTimeout() {
        guard self.localAuthFlow == nil else {
            return
        }
        
        let flow = LocalAuthFlowController(
            account: self.userDataProvider.account,
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            rootNavigation: self.rootNavigation,
            userDataManager: self.managersController.userDataManager,
            keychainManager: self.managersController.keychainManager,
            onAuthorized: { [weak self] in
                self?.onLocalAuthSucceded()
            },
            onRecoverySucceeded: { [weak self] in
                self?.onLocalAuthRecoverySucceeded()
            },
            onSignOut: { [weak self] in
                self?.onSignOut()
            },
            onKYCFailed: {}
        )
        self.localAuthFlow = flow
        flow.run(showRootScreen: nil)
    }
    
    private func onLocalAuthSucceded() {
        self.isAuthorized = true
        self.localAuthFlow = nil
        self.showHomeScreen()
        self.startUserActivityTimer()
    }
}
