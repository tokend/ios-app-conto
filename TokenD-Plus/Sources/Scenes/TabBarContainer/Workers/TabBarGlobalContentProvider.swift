import UIKit
import RxSwift

extension TabBarContainer {
    
    public class GlobalContentProvider {
        
        // MARK: - Private properties
        
        private let ownerAccountId: String
        private let navigationController: NavigationControllerProtocol
        private let backToCompanies: () -> Void
        private let onSignOut: () -> Void
        private let showTabBar: () -> Void
        private let hideTabBar: () -> Void
        
        private let appController: AppControllerProtocol
        private let flowControllerStack: FlowControllerStack
        private let rootNavigation: RootNavigationProtocol
        private let reposController: ReposController
        private let managersController: ManagersController
        private let userDataProvider: UserDataProviderProtocol
        private let keychainDataProvider: KeychainDataProviderProtocol
        
        private var content: TabBarContainer.ContentProtocol?
        private var flowControllers: [FlowControllerProtocol] = []
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        init(
            navigationController: NavigationControllerProtocol,
            ownerAccountId: String,
            backToCompanies: @escaping () -> Void,
            onSignOut: @escaping () -> Void,
            showTabBar: @escaping () -> Void,
            hideTabBar: @escaping () -> Void,
            appController: AppControllerProtocol,
            flowControllerStack: FlowControllerStack,
            rootNavigation: RootNavigationProtocol,
            reposController: ReposController,
            managersController: ManagersController,
            userDataProvider: UserDataProviderProtocol,
            keychainDataProvider: KeychainDataProviderProtocol
            ) {
            
            self.navigationController = navigationController
            self.ownerAccountId = ownerAccountId
            self.backToCompanies = backToCompanies
            self.onSignOut = onSignOut
            self.showTabBar = showTabBar
            self.hideTabBar = hideTabBar
            self.appController = appController
            self.flowControllerStack = flowControllerStack
            self.rootNavigation = rootNavigation
            self.reposController = reposController
            self.managersController = managersController
            self.userDataProvider = userDataProvider
            self.keychainDataProvider = keychainDataProvider
        }
        
        // MARK: - Private
        
        private func setupTabsContainer() -> TabsContainer.ViewController {
            let tabContainer = TabsContainer.ViewController()
            let tabs = self.getTabs()
            let contentProvider = TabsContainer.InfoContentProvider(tabs: tabs)
            let sceneModel = TabsContainer.Model.SceneModel(selectedTabId: nil)
            let viewConfig = TabsContainer.Model.ViewConfig(
                isPickerHidden: true,
                isTabBarHidden: false,
                actionButtonAppearence: .hidden,
                isScrollEnabled: false
            )
            let routing = TabsContainer.Routing(onAction: {
                
            })
            
            self.content = tabContainer
            TabsContainer.Configurator.configure(
                viewController: tabContainer,
                contentProvider: contentProvider,
                sceneModel: sceneModel,
                viewConfig: viewConfig,
                routing: routing
            )
            return tabContainer
        }
        
        private func setupTabBar() -> TabBar.View {
            let tabBar = TabBar.View()
            let sceneModel = TabBar.Model.SceneModel(
                tabs: [],
                selectedTab: nil,
                selectedTabIdentifier: nil
            )
            let tabProvider = TabBar.GlobalNavigationTabProvider()
            let routing = TabBar.Routing(
                onAction: { [weak self] (tabIdentifier) in
                    self?.handleAction(identifier: tabIdentifier)
            })
            
            TabBar.Configurator.configure(
                view: tabBar,
                sceneModel: sceneModel,
                tabProvider: tabProvider,
                routing: routing
            )
            
            return tabBar
        }
        
        private func getTabs() -> [TabsContainer.Model.TabModel] {
            let balancesTab = self.getBalancesTab()
            let salesTab = self.getSalesTab()
            let pollsTab = self.getPollsTab()
            let settingsTab = self.getSettingsTab()
            
            return [balancesTab, salesTab, pollsTab, settingsTab]
        }
        
        // MARK: - Balances Tab
        
        private func getBalancesTab() -> TabsContainer.Model.TabModel {
            let navigationController = NavigationController()
            self.addSubscriptionTo(navigationController: navigationController)
            self.runBalancesFlow(navigationController: navigationController)
            
            return TabsContainer.Model.TabModel(
                title: Localized(.balances),
                content: .viewController(navigationController.getViewController()),
                identifier: Localized(.balances)
            )
        }
        
        private func runBalancesFlow(
            navigationController: NavigationControllerProtocol,
            selectedTabIndetifier: TabsContainer.Model.TabIdentifier? = nil
            ) {
            
            let balancesFlow = DashboardFlowController(
                navigationController: navigationController,
                ownerAccountId: self.ownerAccountId,
                appController: self.appController,
                flowControllerStack: self.flowControllerStack,
                reposController: self.reposController,
                managersController: self.managersController,
                userDataProvider: self.userDataProvider,
                keychainDataProvider: self.keychainDataProvider,
                rootNavigation: self.rootNavigation
            )
            self.flowControllers.append(balancesFlow)
            balancesFlow.run(
                showRootScreen: { (vc) in
                    navigationController.pushViewController(vc, animated: true)
            },
                selectedTabIdentifier: selectedTabIndetifier
            )
        }
        
        // MARK: - Sales Tab
        
        private func getSalesTab() -> TabsContainer.Model.TabModel {
            let navigationController = NavigationController()
            self.addSubscriptionTo(navigationController: navigationController)
            self.runSaleFlow(navigationController: navigationController)
            
            return TabsContainer.Model.TabModel(
                title: Localized(.sales),
                content: .viewController(navigationController.getViewController()),
                identifier: Localized(.sales)
            )
        }
        
        private func runSaleFlow(navigationController: NavigationControllerProtocol) {
            let salesFlow = SalesFlowController(
                navigationController: navigationController,
                ownerAccountId: self.ownerAccountId,
                appController: self.appController,
                flowControllerStack: self.flowControllerStack,
                reposController: self.reposController,
                managersController: self.managersController,
                userDataProvider: self.userDataProvider,
                keychainDataProvider: self.keychainDataProvider,
                rootNavigation: self.rootNavigation
            )
            self.flowControllers.append(salesFlow)
            salesFlow.run(
                showRootScreen: { (vc) in
                    navigationController.pushViewController(vc, animated: false)
            },
                onShowMovements: {
                    _ = navigationController.popToRootViewController(animated: true)
            }
            )
        }
        
        
        // MARK: - Polls Tab
        
        private func getPollsTab() -> TabsContainer.Model.TabModel {
            let navigationController = NavigationController()
            self.addSubscriptionTo(navigationController: navigationController)
            self.runPollsFlow(navigationController: navigationController)
            
            return TabsContainer.Model.TabModel(
                title: Localized(.polls),
                content: .viewController(navigationController.getViewController()),
                identifier: Localized(.polls)
            )
        }
        
        private func runPollsFlow(navigationController: NavigationControllerProtocol) {
            let pollsFlow = PollsFlowController(
                navigationController: navigationController,
                ownerAccountId: self.ownerAccountId,
                appController: self.appController,
                flowControllerStack: self.flowControllerStack,
                reposController: self.reposController,
                managersController: self.managersController,
                userDataProvider: self.userDataProvider,
                keychainDataProvider: self.keychainDataProvider,
                rootNavigation: self.rootNavigation
            )
            self.flowControllers.append(pollsFlow)
            pollsFlow.run(showRootScreen: { (vc) in
                navigationController.pushViewController(vc, animated: false)
            })
        }
        
        // MARK: - Settings Tab
        
        private func getSettingsTab() -> TabsContainer.Model.TabModel {
            let navigationController = NavigationController()
            self.addSubscriptionTo(navigationController: navigationController)
            self.runSettingsFlow(navigationController: navigationController)
            
            return TabsContainer.Model.TabModel(
                title: Localized(.settings),
                content: .viewController(navigationController.getViewController()),
                identifier: Localized(.settings)
            )
        }
        
        private func runSettingsFlow(navigationController: NavigationControllerProtocol) {
            let settingsflow = SettingsFlowController(
                navigationController: navigationController,
                onSignOut: self.onSignOut,
                appController: self.appController,
                flowControllerStack: self.flowControllerStack,
                reposController: self.reposController,
                managersController: self.managersController,
                userDataProvider: self.userDataProvider,
                keychainDataProvider: self.keychainDataProvider,
                rootNavigation: self.rootNavigation
            )
            
            self.flowControllers.append(settingsflow)
            settingsflow.run(showRootScreen: { (vc) in
                navigationController.pushViewController(vc, animated: true)
            })
        }
        
        // MARK: - Handle tab bar visibility
        
        private func addSubscriptionTo(
            navigationController: NavigationControllerProtocol
            ) {
            
            navigationController.observerViewControllersCount()
                .subscribe(onNext: { [weak self] (vcCount) in
                    if vcCount <= 1 {
                        self?.showTabBar()
                    } else {
                        self?.hideTabBar()
                    }
                })
                .disposed(by: self.disposeBag)
        }
        
        // MARK: - Navigation
        
        private func handleAction(identifier: TabIdentifier) {
            if identifier == Localized(.companies) {
                 self.backToCompanies()
            } else {
                self.content?.setContentWithIdentifier(identifier)
            }
        }
    }
}

extension TabBarContainer.GlobalContentProvider: TabBarContainer.ContentProviderProtocol {
    
    public func getSceneContent() -> TabBarContainer.Model.SceneContent {
        let tabsContainer = self.setupTabsContainer()
        let tabBar = self.setupTabBar()
        
        return TabBarContainer.Model.SceneContent.init(
            content: tabsContainer,
            tabBar: tabBar,
            title: ""
        )
    }
}
