import UIKit
import SideMenuController
import TokenDWallet

class CompanyFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol = NavigationController()
    private var companyName: String
    private var ownerAccountId: String
    
    private var flowControllers: [FlowControllerProtocol] = []
    
    // MARK: - Callbacks
    
    let onSignOut: () -> Void
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
        companyName: String,
        ownerAccountId: String,
        onSignOut: @escaping () -> Void,
        onBackToCompanies: @escaping () -> Void
        ) {
        
        self.companyName = companyName
        self.ownerAccountId = ownerAccountId
        self.onSignOut = onSignOut
        self.onBackToCompanies = onBackToCompanies
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        
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
        let tabBarContainer = self.setupTabsNavigationBarContainer()
        self.navigationController.setViewControllers([tabBarContainer], animated: false)
        self.showHomeScreen()
    }
    
    // MARK: - Overridden
    
    // MARK: - Private
    
    private func showHomeScreen() {
        self.rootNavigation.setRootContent(
            self.navigationController,
            transition: .fade,
            animated: true
        )
    }
    
    // MARK: - Setup
    
    private func setupTabsNavigationBarContainer() -> UIViewController {
        let tabBarContainer = TabBarContainer.ViewController()
        
        let showTabBar: () -> Void = {
            tabBarContainer.showTabBar()
        }
        let hideTabBar: () -> Void = {
            tabBarContainer.hideTabBar()
        }
        let backToCompanies: () -> Void = {
            self.onBackToCompanies()
        }
        let globalContentProvider = TabBarContainer.GlobalContentProvider(
            navigationController: self.navigationController,
            ownerAccountId: self.ownerAccountId,
            backToCompanies: backToCompanies,
            onSignOut: self.onSignOut,
            showTabBar: showTabBar,
            hideTabBar: hideTabBar,
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            rootNavigation: self.rootNavigation,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider
        )
        
        let routing = TabBarContainer.Routing()
        
        TabBarContainer.Configurator.configure(
            viewController: tabBarContainer,
            contentProvider: globalContentProvider,
            routing: routing
        )
        self.runReposPreload()
        
        return tabBarContainer
    }
    
    private func getSideMenuHeaderTitle() -> String {
        return AppInfoUtils.getValue(.bundleDisplayName, Localized(.tokend))
    }
    
    // MARK: - Side Menu Navigation
    
    private func runReposPreload() {
        _ = self.reposController.assetsRepo.observeAssets()
        _ = self.reposController.balancesRepo.observeBalancesDetails()
    }
}
