import UIKit
import RxSwift

class BalancesListFlowController: BaseSignedInFlowController {
    
    // MARK: - Private
    
    private let navigationController: NavigationControllerProtocol = NavigationController()
    private weak var balancesScene: BalancesList.ViewController?
    private var balancesCompletionScene: UIViewController {
        return self.balancesScene ?? UIViewController()
    }
    private weak var balanceDetailsScene: FlexibleHeaderContainerViewController?
    private var balanceDetailsCompletionScene: UIViewController {
        return self.balanceDetailsScene ?? UIViewController()
    }
    private let ownerAccountId: String
    private let companyName: String
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: -
    
    init(
        ownerAccountId: String,
        companyName: String,
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol
        ) {
        
        self.ownerAccountId = ownerAccountId
        self.companyName = companyName
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
        showRootScreen: ((_ vc: UIViewController) -> Void)
        ) {
        
        self.showDashboardScreen(showRootScreen: showRootScreen)
    }
    
    // MARK: - Private
    
    private func backToBalances() {
        _ = self.navigationController.popToViewController(
            self.balancesCompletionScene,
            animated: true
        )
    }
    
    private func backToBalanceDetails() {
        _ = self.navigationController.popToViewController(
            self.balanceDetailsCompletionScene,
            animated: true
        )
    }
    
    private func showDashboardScreen(
        showRootScreen: ((_ vc: UIViewController) -> Void)
        ) {
        
        let vc = self.setupBalancesListScene()
        vc.navigationItem.title = companyName
        
        self.navigationController.setViewControllers([vc], animated: false)
        showRootScreen(self.navigationController.getViewController())
    }
    
    private func setupBalancesListScene() -> UIViewController {
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
            },
            showReceive: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.showReceiveScene(navigationController: strongSelf.navigationController)
            },
            showCreateRedeem: { [weak self] in
                guard let strongSelf = self else { return }
                self?.runCreateRedeemFlow(
                    navigationController: strongSelf.navigationController,
                    companyName: strongSelf.companyName,
                    ownerAccountId: strongSelf.ownerAccountId,
                    balanceId: nil
                )
        },
            showAcceptRedeem: { [weak self] in
                guard let strongSelf = self else { return }
                self?.runAcceptRedeemFlow(navigationController: strongSelf.navigationController)
            },
            showSendPayment: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.runSendPaymentFlow(
                    navigationController: strongSelf.navigationController,
                    ownerAccountId: strongSelf.ownerAccountId,
                    balanceId: nil,
                    completion: {
                        strongSelf.backToBalances()
                })
            }
        )
        
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
        
        self.balancesScene = vc
        return vc
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
            balancesRepo: self.reposController.balancesRepo,
            originalAccountId: self.userDataProvider.walletData.accountId
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
                        self?.backToBalanceDetails()
                })
            },
            showCreateReedeem: { [weak self] (balanceId) in
                self?.runCreateRedeemFlow(
                    navigationController: navigationController,
                    companyName: self?.companyName ?? "",
                    ownerAccountId: self?.ownerAccountId ?? "",
                    balanceId: balanceId
                )
            },
            showAcceptRedeem: { [weak self] in
                self?.runAcceptRedeemFlow(navigationController: navigationController)
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
        self.balanceDetailsScene = container
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
            balancesRepo: self.reposController.balancesRepo,
            originalAccountId: self.userDataProvider.walletData.accountId
        )
        
        let viewConfig = TransactionsListScene.Model.ViewConfig(actionButtonIsHidden: true)
        
        let transactionsListRouting = TransactionsListScene.Routing(
            onDidSelectItemWithIdentifier: { [weak self] (identifier, _) in
                self?.showPendingOfferDetailsScreen(offerId: identifier)
            },
            showSendPayment: { _ in },
            showCreateReedeem: { _ in },
            showAcceptRedeem: { },
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
    
    private func shareItems(_ items: [Any]) {
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.navigationController.present(activity, animated: true, completion: nil)
    }
}
