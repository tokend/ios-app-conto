import UIKit
import TokenDWallet

class CompanyFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol = NavigationController()
    private var companyName: String
    private var ownerAccountId: String
    
    private var flowControllers: [FlowControllerProtocol] = []
    
    // MARK: - Callbacks
    
    let onSignOut: () -> Void
    let updateLanguageContent: () -> Void
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
        updateLanguageContent: @escaping () -> Void,
        onSignOut: @escaping () -> Void,
        onBackToCompanies: @escaping () -> Void
        ) {
        
        self.companyName = companyName
        self.ownerAccountId = ownerAccountId
        self.updateLanguageContent = updateLanguageContent
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
        self.navigationController.setViewControllers([tabBarContainer], animated: true)
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
        let backToCompanies: () -> Void = { [weak self] in
            self?.onBackToCompanies()
        }
        let showSendScene: () -> Void = { [weak self] in
            self?.showSendScene()
        }
        let showReceiveScene: () -> Void = { [weak self] in
            self?.showReceiveScene()
        }
        let showCreateRedeemScene: () -> Void = { [weak self] in
            self?.showCreateRedeemScene()
        }
        let acceptRedeemScene: () -> Void = { [weak self] in
            self?.showAcceptRedeemScene()
        }
        let globalContentProvider = TabBarContainer.GlobalContentProvider(
            navigationController: self.navigationController,
            ownerAccountId: self.ownerAccountId,
            backToCompanies: backToCompanies,
            showSendScene: showSendScene,
            showReceiveScene: showReceiveScene,
            showCreateRedeemScene: showCreateRedeemScene,
            showAcceptRedeemScene: acceptRedeemScene,
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
    
    private func showCreateRedeemScene() {
        self.runCreateRedeemFlow(
            navigationController: self.navigationController,
            ownerAccountId: self.ownerAccountId,
            balanceId: nil
        )
    }
    
    private func showAcceptRedeemScene() {
        self.runAcceptRedeemFlow(navigationController: self.navigationController)
    }
    
    private func showSendScene() {
        self.runSendPaymentFlow(
            navigationController: self.navigationController,
            ownerAccountId: self.ownerAccountId,
            balanceId: nil,
            completion: { [weak self] in
                _ = self?.navigationController.popToRootViewController(animated: true)
        })
    }
    
    private func showReceiveScene() {
        let vc = ReceiveAddress.ViewController()
        
        let addressManager = ReceiveAddress.ReceiveAddressManager(
            accountId: self.userDataProvider.walletData.accountId,
            email: self.userDataProvider.account
        )
        
        let viewConfig = ReceiveAddress.Model.ViewConfig(
            copiedLocalizationKey: Localized(.copied),
            tableViewTopInset: 24,
            headerAppearence: .hidden
        )
        
        let sceneModel = ReceiveAddress.Model.SceneModel()
        
        let qrCodeGenerator = QRCodeGenerator()
        let shareUtil = ReceiveAddress.ReceiveAddressShareUtil(
            qrCodeGenerator: qrCodeGenerator
        )
        
        let invoiceFormatter = ReceiveAddress.InvoiceFormatter()
        
        let routing = ReceiveAddress.Routing(
            onCopy: { (stringToCopy) in
                UIPasteboard.general.string = stringToCopy
        },
            onShare: { [weak self] (itemsToShare) in
                self?.shareItems(itemsToShare)
        })
        
        ReceiveAddress.Configurator.configure(
            viewController: vc,
            viewConfig: viewConfig,
            sceneModel: sceneModel,
            addressManager: addressManager,
            shareUtil: shareUtil,
            qrCodeGenerator: qrCodeGenerator,
            invoiceFormatter: invoiceFormatter,
            routing: routing
        )
        
        vc.navigationItem.title = Localized(.account_capitalized)
        vc.tabBarItem.title = Localized(.receive)
        vc.tabBarItem.image = Assets.receive.image
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func getSideMenuHeaderTitle() -> String {
        return AppInfoUtils.getValue(.bundleDisplayName, Localized(.tokend))
    }
    
    // MARK: - Side Menu Navigation
    
    private func runReposPreload() {
        _ = self.reposController.assetsRepo.observeAssets()
        _ = self.reposController.balancesRepo.observeBalancesDetails()
    }
    
    private func shareItems(_ items: [Any]) {
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.navigationController.present(activity, animated: true, completion: nil)
    }
}
