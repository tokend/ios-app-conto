import UIKit
import RxSwift

class BalancesListFlowController: BaseSignedInFlowController {
    
    // MARK: - Private
    
    private let navigationController: NavigationControllerProtocol
    private weak var dashboardScene: BalancesList.ViewController?
    private var operationCompletionScene: UIViewController {
        return self.dashboardScene ?? UIViewController()
    }
    private let ownerAccountId: String
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: -
    
    init(
        navigationController: NavigationControllerProtocol,
        ownerAccountId: String,
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol
        ) {
        
        self.navigationController = navigationController
        self.ownerAccountId = ownerAccountId
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
    
    public func run(
        showRootScreen: ((_ vc: UIViewController) -> Void),
        selectedTabIdentifier: TabsContainer.Model.TabIdentifier?
        ) {
        
        self.showDashboardScreen(
            showRootScreen: showRootScreen,
            selectedTabIdentifier: selectedTabIdentifier
        )
    }
    
    // MARK: - Private
    
    private func showMovements() {
        _ = self.navigationController.popToViewController(
            self.operationCompletionScene,
            animated: true
        )
    }
    
    private func showDashboardScreen(
        showRootScreen: ((_ vc: UIViewController) -> Void),
        selectedTabIdentifier: TabsContainer.Model.TabIdentifier?
        ) {
        
        let vc = BalancesList.ViewController()
        let sceneModel = BalancesList.Model.SceneModel(
            balances: [],
            chartBalances: [],
            selectedChartBalance: nil,
            convertedAsset: "USD"
        )
        let amountFormatter = BalancesList.AmountFormatter()
        let percentFormatter = BalancesList.PercentFormatter()
        
        let imagesUtility = ImagesUtility(
            storageUrl: self.flowControllerStack.apiConfigurationModel.storageEndpoint
        )
        let balancesFetcher = BalancesList.BalancesFetcher(
            balancesRepo: self.reposController.balancesRepo,
            assetsRepo: self.reposController.assetsRepo,
            ownerAccountId: self.ownerAccountId,
            imageUtility: imagesUtility
        )
        let actionProvider = BalancesList.ActionProvider(
            originalAccountId: self.userDataProvider.walletData.accountId,
            ownerAccountId: ownerAccountId
            )
        let colorsProvider = BalancesList.PieChartColorsProvider()
        
        let routing = BalancesList.Routing(
            onBalanceSelected: { [weak self] (balanceId) in
                self?.showPaymentsFor(selectedBalanceId: balanceId)
            },
            showProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            },
            showShadow: { [weak self] in
                self?.navigationController.showShadow()
            },
            hideShadow: { [weak self] in
                self?.navigationController.hideShadow()
            })
        
        BalancesList.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            balancesFetcher: balancesFetcher,
            actionProvider: actionProvider,
            amountFormatter: amountFormatter,
            percentFormatter: percentFormatter,
            colorsProvider: colorsProvider,
            routing: routing
        )
        
        self.dashboardScene = vc
        
        vc.navigationItem.title = Localized(.balances)
        
        showRootScreen(vc)
    }
    
    private func showPaymentsFor(selectedBalanceId: String) {
        let transactionsProvider = TransactionsListScene.HistoryProvider(
            reposController: self.reposController,
            originalAccountId: self.userDataProvider.walletData.accountId
        )
        let transactionsFetcher = TransactionsListScene.PaymentsFetcher(
            transactionsProvider: transactionsProvider
        )
        
        let actionProvider = TransactionsListScene.ActionProvider(
            assetsRepo: self.reposController.assetsRepo,
            balancesRepo: self.reposController.balancesRepo
        )
        
        let viewConfig = TransactionsListScene.Model.ViewConfig(actionButtonIsHidden: false)
        
        let navigationController = self.navigationController
        let transactionsRouting = TransactionsListScene.Routing (
            onDidSelectItemWithIdentifier: { [weak self] (identifier, balanceId) in
                self?.showTransactionDetailsScreen(
                    transactionsProvider: transactionsProvider,
                    navigationController: navigationController,
                    transactionId: identifier,
                    balanceId: balanceId
                )
            },
            showSendPayment: { [weak self] (balanceId) in
                self?.runSendPaymentFlow(
                    navigationController: navigationController,
                    ownerAccountId: self?.ownerAccountId ?? "",
                    balanceId: balanceId,
                    completion: { [weak self] in
                        self?.showMovements()
                })
            },
            showWithdraw: { [weak self] (balanceId) in
                self?.runWithdrawFlow(
                    navigationController: navigationController,
                    ownerAccountId: self?.ownerAccountId ?? "",
                    balanceId: balanceId,
                    completion: { [weak self] in
                        self?.showMovements()
                })
            },
            showDeposit: { [weak self] (asset) in
                self?.showDepositScreen(
                    navigationController: navigationController,
                    assetId: asset
                )
            },
            showReceive: { [weak self] in
                self?.showReceiveScene(navigationController: navigationController)
            },
            showBuy: { [weak self] (asset) in
                self?.runAtomicSwapFlow(
                    navigationController: navigationController,
                    asset: asset
                )
            },
            showShadow: { [weak self] in
                self?.navigationController.showShadow()
            },
            hideShadow: { [weak self] in
                self?.navigationController.hideShadow()
        })
        
        let imageUtility = ImagesUtility(
            storageUrl: self.flowControllerStack.apiConfigurationModel.storageEndpoint
        )
        let balanceFetcher = BalanceHeader.BalancesFetcher(
            balancesRepo: self.reposController.balancesRepo,
            assetsRepo: self.reposController.assetsRepo,
            imageUtility: imageUtility,
            balanceId: selectedBalanceId
        )
        let container = SharedSceneBuilder.createBalanceDetailsScene(
            transactionsFetcher: transactionsFetcher,
            actionProvider: actionProvider,
            transactionsRouting: transactionsRouting,
            viewConfig: viewConfig,
            balanceFetcher: balanceFetcher,
            balanceId: selectedBalanceId
        )
        self.navigationController.pushViewController(container, animated: true)
    }
    
    private func showPendingOffers() {
        let decimalFormatter = DecimalFormatter()
        let transactionsFetcher = TransactionsListScene.PendingOffersFetcher(
            pendingOffersRepo: self.reposController.pendingOffersRepo,
            balancesRepo: self.reposController.balancesRepo,
            decimalFormatter: decimalFormatter,
            originalAccountId: self.userDataProvider.walletData.accountId
        )
        
        let actionProvider = TransactionsListScene.ActionProvider(
            assetsRepo: self.reposController.assetsRepo,
            balancesRepo: self.reposController.balancesRepo
        )
        
        let viewConfig = TransactionsListScene.Model.ViewConfig(actionButtonIsHidden: true)
        
        let transactionsListRouting = TransactionsListScene.Routing(
            onDidSelectItemWithIdentifier: { [weak self] (identifier, _) in
                self?.showPendingOfferDetailsScreen(offerId: identifier)
            },
            showSendPayment: { _ in },
            showWithdraw: { _ in },
            showDeposit: { _ in },
            showReceive: { },
            showBuy: { _ in },
            showShadow: { [weak self] in
                self?.navigationController.showShadow()
            },
            hideShadow: { [weak self] in
                self?.navigationController.hideShadow()
            }
        )
        
        let viewController = SharedSceneBuilder.createTransactionsListScene(
            transactionsFetcher: transactionsFetcher,
            actionProvider: actionProvider,
            emptyTitle: Localized(.no_pending_orders),
            viewConfig: viewConfig,
            routing: transactionsListRouting
        )
        
        viewController.navigationItem.title = Localized(.pending_orders)
        
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showPendingOfferDetailsScreen(
        offerId: UInt64
        ) {
        
        let sectionsProvider = TransactionDetails.PendingOfferSectionsProvider(
            pendingOffersRepo: self.reposController.pendingOffersRepo,
            transactionSender: self.managersController.transactionSender,
            amountConverter: AmountConverter(),
            networkInfoFetcher: self.flowControllerStack.networkInfoFetcher,
            userDataProvider: self.userDataProvider,
            identifier: offerId
        )
        let vc = self.setupTransactionDetailsScreen(
            navigationController: self.navigationController,
            sectionsProvider: sectionsProvider,
            title: Localized(.pending_order_details)
        )
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func runExploreTokensFlow() {
        let exploreTokensFlowController = ExploreTokensFlowController(
            navigationController: self.navigationController,
            ownerAccountId: self.ownerAccountId,
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation
        )
        self.currentFlowController = exploreTokensFlowController
        exploreTokensFlowController.run(showRootScreen: { [weak self] (vc) in
            self?.navigationController.pushViewController(vc, animated: true)
        })
    }
    
    private func shareItems(_ items: [Any]) {
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.navigationController.present(activity, animated: true, completion: nil)
    }
}
