import UIKit
import SideMenuController
import TokenDWallet

class CompanyFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let sideNavigationController: SideMenuController
    
    private let sideMenuViewController = SideMenu.ViewController()
    
    private let exploreTokensIdentifier: String = "ExploreTokens"
    private let sendPaymentIdentifier: String = "SendPayment"
    private let ownerAccountId: String
    
    // MARK: - Callbacks
    
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
        onBackToCompanies: @escaping () -> Void
        ) {
        
        self.ownerAccountId = ownerAccountId
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
    }
    
    // MARK: - Public
    
    public func run() {
        self.setupSideMenu()
        self.showHomeScreen()
    }
    
    // MARK: - Overridden
    
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
            icon: #imageLiteral(resourceName: "Icon").withRenderingMode(.alwaysTemplate),
            title: self.getSideMenuHeaderTitle(),
            subTitle: self.userDataProvider.userEmail
        )
        
        let sections: [[SideMenu.Model.MenuItem]] = [
            [
                SideMenu.Model.MenuItem(
                    iconImage: Assets.dashboardIcon.image,
                    title: Localized(.dashboard),
                    onSelected: { [weak self] in
                        self?.runDashboardFlow()
                }),
                SideMenu.Model.MenuItem(
                    iconImage: Assets.exploreFundsIcon.image,
                    title: Localized(.sales),
                    onSelected: { [weak self] in
                        self?.runExploreFundsFlow()
                }),
                SideMenu.Model.MenuItem(
                    iconImage: Assets.polls.image,
                    title: Localized(.polls),
                    onSelected: { [weak self] in
                        self?.runPollsFlow()
                }),
                SideMenu.Model.MenuItem(
                    iconImage: Assets.companies.image,
                    title: Localized(.back_to_companies),
                    onSelected: { [weak self] in
                        self?.onBackToCompanies()
                })
            ]
        ]
        
        SideMenu.Configurator.configure(
            viewController: self.sideMenuViewController,
            header: headerModel,
            sections: sections,
            routing: SideMenu.Routing()
        )
        
        self.sideNavigationController.embed(sideViewController: self.sideMenuViewController)
        self.runReposPreload()
        self.runDashboardFlow()
    }
    
    private func getSideMenuHeaderTitle() -> String {
        return AppInfoUtils.getValue(.bundleDisplayName, Localized(.tokend))
    }
    
    // MARK: - Side Menu Navigation
    
    private func runReposPreload() {
        _ = self.reposController.assetsRepo.observeAssets()
        _ = self.reposController.balancesRepo.observeBalancesDetails()
    }
    
    private func runWalletFlow(selectedBalanceId: String) {
        let walletDetailsFlowController = WalletDetailsFlowController(
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation
        )
        self.currentFlowController = walletDetailsFlowController
        walletDetailsFlowController.run(
            showRootScreen: { [weak self] (vc) in
                self?.sideNavigationController.embed(centerViewController: vc)
            },
            selectedBalanceId: selectedBalanceId
        )
    }
    
    private func runDashboardFlow(
        selectedTabIndetifier: TabsContainer.Model.TabIdentifier? = nil
        ) {
        
        let dashboardFlowController = DashboardFlowController(
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation,
            ownerAccountId: self.ownerAccountId
        )
        self.currentFlowController = dashboardFlowController
        dashboardFlowController.run(
            showRootScreen: { [weak self] (vc) in
                self?.sideNavigationController.embed(centerViewController: vc)
            },
            selectedTabIdentifier: selectedTabIndetifier
        )
    }
    
    private func runExploreFundsFlow() {
        let flow = SalesFlowController(
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation,
            ownerAccountId: self.ownerAccountId
        )
        self.currentFlowController = flow
        flow.run(
            showRootScreen: { [weak self] (vc) in
                self?.sideNavigationController.embed(centerViewController: vc)
            },
            onShowMovements: { [weak self]  in
                self?.runDashboardFlow(selectedTabIndetifier: Localized(.movements))
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
            selectedBalanceId: nil
        )
        self.currentFlowController = flow
        flow.run(
            showRootScreen: { [weak self] (vc) in
                navigationController.setViewControllers([vc], animated: false)
                self?.sideNavigationController.embed(centerViewController: navigationController)
            },
            onShowMovements: { [weak self] in
                self?.runDashboardFlow(selectedTabIndetifier: Localized(.movements))
        })
    }
    
    private func runSaleFlow() {
        let flow = SalesFlowController(
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation,
            ownerAccountId: self.ownerAccountId
        )
        self.currentFlowController = flow
        flow.run(
            showRootScreen: { [weak self] (vc) in
                self?.sideNavigationController.embed(centerViewController: vc)
            },
            onShowMovements: { [weak self] in
                self?.runDashboardFlow()
        })
    }
    
    private func runPollsFlow() {
        let flow = PollsFlowController(
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation,
            ownerAccountId: self.ownerAccountId
        )
        self.currentFlowController = flow
        flow.run(showRootScreen: { [weak self] (vc) in
            self?.sideNavigationController.embed(centerViewController: vc)
        })
    }
}
