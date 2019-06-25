import UIKit
import TokenDSDK
import RxSwift

class CompaniesListFlowController: BaseSignedInFlowController {
    
    // MARK: - Public properties
    
    static let userActionsTimeout: TimeInterval = 15 * 60
    static let backgroundTimeout: TimeInterval = 15 * 60
    
    private(set) var isAuthorized: Bool = true
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol = NavigationController()
    private let disposeBag: DisposeBag = DisposeBag()
    private let onSignOut: () -> Void
    private let onLocalAuthRecoverySucceeded: () -> Void
    
    private var localAuthFlow: LocalAuthFlowController?
    private var timeoutSubscribeToken: TimerUIApplication.SubscribeToken = TimerUIApplication.SubscribeTokenInvalid
    private var backgroundTimer: Timer?
    private var backgroundToken: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    // MARK: -
    
    init(
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol,
        onSignOut: @escaping (() -> Void),
        onLocalAuthRecoverySucceeded: @escaping () -> Void
        ) {
        
        self.onSignOut = onSignOut
        self.onLocalAuthRecoverySucceeded = onLocalAuthRecoverySucceeded
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
    
    public func run() {
        self.showCompaniesScreen()
        self.startUserActivityTimer()
    }
    
    // MARK: - Private
    
    private func showCompaniesScreen() {
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
        
        let settingsItem = UIBarButtonItem(
            image: Assets.settingsIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        settingsItem
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] (_) in
                self?.runSettingsFlow()
            })
            .disposed(by: self.disposeBag)
        
        vc.navigationItem.leftBarButtonItem = settingsItem
        let companiesFetcher = CompaniesList.CompaniesFetcher()
        let routing = CompaniesList.Routing(
            showLoading: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideLoading: { [weak self] in
                self?.navigationController.hideProgress()
            },
            onCompanyChosen: { [weak self] (accountId) in
                self?.runCompanyFlow(ownerAccountId: accountId)
        })
        CompaniesList.Configurator.configure(
            viewController: vc,
            companiesFetcher: companiesFetcher,
            routing: routing
        )
        
        return vc
    }
    
    private func runSettingsFlow() {
        let flow = SettingsFlowController(
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation,
            navigationController: self.navigationController,
            onSignOut: self.onSignOut
        )
        self.currentFlowController = flow
        flow.run()
    }
    
    private func runCompanyFlow(ownerAccountId: String) {
        let flow = CompanyFlowController(
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation,
            ownerAccountId: ownerAccountId,
            onBackToCompanies: { [weak self] in
                self?.run()
            })
        self.currentFlowController = flow
        flow.run()
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
            userDataManager: self.managersController.userDataManager,
            keychainManager: self.managersController.keychainManager
        )
        
        signOutWorker.performSignOut(completion: { [weak self] in
            self?.onSignOut()
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
        })
        self.localAuthFlow = flow
        flow.run(showRootScreen: nil)
    }
    
    private func onLocalAuthSucceded() {
        self.isAuthorized = true
        self.localAuthFlow = nil
        self.showCompaniesScreen()
        self.startUserActivityTimer()
    }
}
