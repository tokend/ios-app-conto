import UIKit
import TokenDWallet
import SideMenuController

class CompanyFlowController: BaseSignedInFlowController {
    
    // MARK: - Public properties
    
    static let userActionsTimeout: TimeInterval = 15 * 60
    static let backgroundTimeout: TimeInterval = 15 * 60
    
    private(set) var isAuthorized: Bool = true
    
    // MARK: - Private properties
    
    private let sideNavigationController: SideMenuController
    
    private let sideMenuViewController = SideMenu.ViewController()
    
    private var localAuthFlow: LocalAuthFlowController?
    private var timeoutSubscribeToken: TimerUIApplication.SubscribeToken = TimerUIApplication.SubscribeTokenInvalid
    private var backgroundTimer: Timer?
    private var backgroundToken: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private let ownerAccountId: String
    private let companyName: String
    
    // MARK: - Callbacks
    
    let onSignOut: () -> Void
    let onLocalAuthRecoverySucceeded: () -> Void
    let onBackToCompanies: () -> Void
    
    // MARK: -
    
    init(
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol,
        ownerAccountId: String,
        companyName: String,
        onSignOut: @escaping () -> Void,
        onLocalAuthRecoverySucceeded: @escaping () -> Void,
        onBackToCompanies: @escaping () -> Void
        ) {
        
        self.ownerAccountId = ownerAccountId
        self.companyName = companyName
        self.onSignOut = onSignOut
        self.onLocalAuthRecoverySucceeded = onLocalAuthRecoverySucceeded
        self.onBackToCompanies = onBackToCompanies
        
        SideMenuController.preferences.drawing.menuButtonImage = Assets.menuIcon.image
        SideMenuController.preferences.drawing.menuButtonWidth = 35
        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.animating.statusBarBehaviour = .horizontalPan
        SideMenuController.preferences.animating.transitionAnimator = nil
        
        self.sideNavigationController = SideMenuController()
        
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
    
    // MARK: - Public
    
    public func run() {
        self.setupSideMenu()
        self.showHomeScreen()
        self.startUserActivityTimer()
    }
    
    // MARK: - Overridden
    
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
    
    // MARK: - Private
    
    private func showHomeScreen() {
        self.rootNavigation.setRootContent(
            self.sideNavigationController,
            transition: .fade,
            animated: true
        )
    }
    
    // MARK: - Setup
    
    private func setupSideMenu() {
        let headerModel = SideMenu.Model.HeaderModel(
            icon: Assets.logo.image,
            title: self.userDataProvider.userEmail,
            subTitle: self.companyName
        )
        let sections: [[SideMenu.Model.MenuItem]] = []
        
        SideMenu.Configurator.configure(
            viewController: self.sideMenuViewController,
            header: headerModel,
            sections: sections,
            routing: SideMenu.Routing(
                showBalances: { [weak self] in
                    self?.runBalancesFlow()
                },
                showSettings: { [weak self] in
                    self?.runSettingsFlow()
                },
                showCompanies: { [weak self] in
                    self?.runCompanyListFlow()
                },
                showReceive: { [weak self] in
                    self?.showReceiveScene()
                })
        )
        
        self.sideNavigationController.embed(sideViewController: self.sideMenuViewController)
        self.runReposPreload()
        self.runBalancesFlow()
    }
    
    // MARK: - Side Menu Navigation
    
    private func runReposPreload() {
        _ = self.reposController.assetsRepo.observeAssets()
        _ = self.reposController.balancesRepo.observeBalancesDetails()
    }
    
    private func runBalancesFlow() {
        let balancesFlow = BalancesListFlowController(
            ownerAccountId: self.ownerAccountId,
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation
        )
        self.currentFlowController = balancesFlow
        balancesFlow.run(
            showRootScreen: { [weak self] (vc) in
                self?.sideNavigationController.embed(centerViewController: vc)
        })
    }
    
    private func runSendPaymentFlow() {
        let navigationController = NavigationController()
        let flow = SendPaymentFlowController(
            navigationController: navigationController,
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation,
            ownerAccountId: self.ownerAccountId,
            selectedBalanceId: nil
        )
        self.currentFlowController = flow
        flow.run(
            showRootScreen: { [weak self] (vc) in
                navigationController.setViewControllers([vc], animated: false)
                self?.sideNavigationController.embed(centerViewController: navigationController)
            },
            onShowMovements: { }
        )
    }
    
    private func runSettingsFlow() {
        let flow = SettingsFlowController(
            onSignOut: self.onSignOut,
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation
        )
        self.currentFlowController = flow
        flow.run(showRootScreen: { [weak self] (vc) in
            self?.sideNavigationController.embed(centerViewController: vc)
        })
    }
    
    private func runSaleFlow() {
        let flow = SalesFlowController(
            ownerAccountId: self.ownerAccountId,
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation
        )
        self.currentFlowController = flow
        flow.run(
            showRootScreen: { [weak self] (vc) in
                self?.sideNavigationController.embed(centerViewController: vc)
            },
            onShowMovements: {}
        )
    }
    
    private func runPollsFlow() {
        let flow = PollsFlowController(
            ownerAccountId: self.ownerAccountId,
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation
        )
        self.currentFlowController = flow
        flow.run(showRootScreen: { [weak self] (vc) in
            self?.sideNavigationController.embed(centerViewController: vc)
        })
    }
    
    private func runCompanyListFlow() {
        let flowController = CompaniesListFlowController(
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation,
            onSignOut: { [weak self] in
                self?.initiateSignOut()
            },
            onLocalAuthRecoverySucceeded: { [weak self] in
                self?.onLocalAuthRecoverySucceeded()
        })
        self.currentFlowController = flowController
        flowController.run(showRootScreen: { [weak self] (vc) in
            self?.sideNavigationController.embed(centerViewController: vc)
        })
    }
    
    private func showReceiveScene() {
        let navigationController = NavigationController()
        self.showReceiveScene(navigationController: navigationController)
        self.sideNavigationController.embed(
            centerViewController: navigationController.getViewController()
        )
    }
    
    // MARK: - Sign Out
    
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
        
        self.sideNavigationController.present(alert, animated: true, completion: nil)
    }
    
    private func performSignOut() {
        let signOutWorker = RegisterScene.LocalSignInWorker(
            settingsManager: self.managersController.settingsManager,
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
            withTimeInterval: CompanyFlowController.backgroundTimeout,
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
        self.showHomeScreen()
        self.startUserActivityTimer()
    }
}
