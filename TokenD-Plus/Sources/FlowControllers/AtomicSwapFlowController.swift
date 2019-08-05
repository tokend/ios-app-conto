import UIKit
import RxSwift

class AtomicSwapFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol
    private let asset: String
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: -
    
    init(
        navigationController: NavigationControllerProtocol,
        asset: String,
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol
        ) {
        
        self.navigationController = navigationController
        self.asset = asset
        
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
    
    func run(showRootScreen: @escaping ((_ vc: UIViewController) -> Void)) {
        let vc = self.setupAtomicSwapScene()
        
        vc.navigationItem.title = Localized(
            .buy_asset,
            replace: [
                .buy_asset_replace_asset: self.asset
            ]
        )
        showRootScreen(vc)
    }
    
    // MARK: - Private
    
    private func setupAtomicSwapScene() -> UIViewController {
        let vc = AtomicSwap.ViewController()
        let asksRepo = self.reposController.getAtomicSwapAsksRepo(for: self.asset)
        let asksFetcher = AtomicSwap.AsksFetcher(asksRepo: asksRepo)
        let sceneModel = AtomicSwap.Model.SceneModel(
            asset: self.asset,
            asks: []
        )
        let amountFormatter = AtomicSwap.AmountFormatter()
        
        let routing = AtomicSwap.Routing(
            showLoading: { [weak self] in
                self?.navigationController.showProgress()
        },
            hideLoading: { [weak self] in
                self?.navigationController.hideProgress()
        },
            showShadow: { [weak self] in
                self?.navigationController.showShadow()
        },
            hideShadow: { [weak self] in
                self?.navigationController.hideShadow()
            },
            onBuyAction: { [weak self] (ask) in
                self?.showAtomicSwapBuyScene(ask: ask)
        })
        
        AtomicSwap.Configurator.configure(
            viewController: vc,
            asksFetcher: asksFetcher,
            sceneModel: sceneModel,
            amountFormatter: amountFormatter,
            routing: routing
        )
        
        return vc
    }
    
    private func showAtomicSwapBuyScene(ask: AtomicSwap.Model.Ask) {
        let vc = self.setupAtomicSwapBuyScreen(ask: ask)
        
        vc.navigationItem.title = Localized(
            .buy_asset,
            replace: [
                .buy_asset_replace_asset: ask.available.asset
            ]
        )
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupAtomicSwapBuyScreen(ask: AtomicSwap.Model.Ask) -> SendPaymentAmount.ViewController {
        let vc = SendPaymentAmount.ViewController()
        
        let buyPreposition = SendPaymentAmount.Model.BalanceDetails(
            asset: ask.available.asset,
            balance: ask.available.value,
            balanceId: ""
        )
        let balanceDetailsLoader = SendPaymentAmount.AtomicSwapBalanceFetcherWorker(
            buyPreposition: buyPreposition
        )
        
        let amountFormatter = SendPaymentAmount.AmountFormatter()
        
        let feeLoader = FeeLoader(
            generalApi: self.flowControllerStack.api.generalApi
        )
        let feeLoaderWorker = SendPaymentAmount.FeeLoaderWorker(
            feeLoader: feeLoader
        )
        let feeOverviewer = SendPaymentAmount.FeeOverviewer(
            generalApi: self.flowControllerStack.api.generalApi,
            accountId: self.userDataProvider.walletData.accountId
        )
        
        let sceneModel = SendPaymentAmount.Model.SceneModel(
            feeType: .payment,
            operation: .handleAtomicSwap(ask)
        )
        
        let viewConfig = SendPaymentAmount.Model.ViewConfig.atomicSwapViewConfig()
        
        let routing = SendPaymentAmount.Routing(
            onShowProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            onHideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            },
            onShowError: { [weak self] (errorMessage) in
                self?.navigationController.showErrorMessage(errorMessage, completion: nil)
            },
            onPresentPicker: { (_, _) in },
            onSendAction: { _ in },
            onAtomicSwapBuyAction: { [weak self] (askModel) in
                self?.showPaymentMethodScene(askModel: askModel)
            },
            onShowWithdrawDestination: nil,
            onShowRedeem: nil,
            showFeesOverview: { _, _ in })
        
        SendPaymentAmount.Configurator.configure(
            viewController: vc,
            senderAccountId: self.userDataProvider.walletData.accountId,
            selectedBalanceId: nil,
            sceneModel: sceneModel,
            balanceDetailsLoader: balanceDetailsLoader,
            amountFormatter: amountFormatter,
            feeLoader: feeLoaderWorker,
            feeOverviewer: feeOverviewer,
            viewConfig: viewConfig,
            routing: routing
        )
        
        return vc
    }
    
    
    private func showPaymentMethodScene(askModel: SendPaymentAmount.Model.AskModel) {
        let vc = self.setupPaymentMethodScene(askModel: askModel)
        vc.navigationItem.title = Localized(.payment_amount)
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupPaymentMethodScene(askModel: SendPaymentAmount.Model.AskModel) -> UIViewController {
        let vc = PaymentMethod.ViewController()
        
        let paymentMethodsFetcher = PaymentMethod.AtomicSwapAsksPaymentMethodsFetcher(
            quoteAssets: askModel.ask.prices
        )
        let amountConverter = AmountConverter()
        
        let paymentWorker = PaymentMethod.AtomicSwapPaymentWorker(
            accountsApi: self.flowControllerStack.apiV3.accountsApi,
            requestsApi: self.flowControllerStack.apiV3.requetsApi,
            networkFetcher: self.reposController.networkInfoRepo,
            transactionSender: self.managersController.transactionSender,
            amountConverter: amountConverter,
            askModel: askModel,
            originalAccountId: self.userDataProvider.walletData.accountId
        )
        
        let sceneModel = PaymentMethod.Model.SceneModel(
            baseAsset: askModel.ask.available.asset,
            baseAmount: askModel.amount,
            methods: [],
            selectedPaymentMethod: nil
        )
        
        let amountFormatter = PaymentMethod.AmountFormatter()
        
        let routing = PaymentMethod.Routing(
            onPickPaymentMethod: { [weak self] (methods, completion) in
                self?.showPaymentMethodPickerScene(
                    methods: methods,
                    completion: completion
                )
            }, showError: { [weak self] (message) in
                self?.navigationController.showErrorMessage(message, completion: nil)
            }, showAtomicSwapInvoice: { [weak self] (model) in
                
            }, showLoading: { [weak self] in
                self?.navigationController.showProgress()
            }, hideLoading: { [weak self] in
                self?.navigationController.hideProgress()
        })
        
        PaymentMethod.Configurator.configure(
            viewController: vc,
            paymentMethodsFetcher: paymentMethodsFetcher,
            paymentWorker: paymentWorker,
            sceneModel: sceneModel,
            amountFormatter: amountFormatter,
            routing: routing
        )
        return vc
    }
    
    private func showPaymentMethodPickerScene(
        methods: [PaymentMethod.Model.PaymentMethod],
        completion: (@escaping(_ asset: String) -> Void)
        ) {
        
        let navController = NavigationController()
        
        let vc = self.setupPaymentMethodPickerScene(
            methods: methods,
            completion: completion
        )
        vc.navigationItem.title = Localized(.payment_method)
        let closeBarItem = UIBarButtonItem(
            title: Localized(.back),
            style: .plain,
            target: nil,
            action: nil
        )
        closeBarItem
            .rx
            .tap
            .asDriver()
            .drive(onNext: { _ in
                navController
                    .getViewController()
                    .dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        vc.navigationItem.leftBarButtonItem = closeBarItem
        navController.setViewControllers([vc], animated: false)
        
        self.navigationController.present(
            navController.getViewController(),
            animated: true,
            completion: nil
        )
    }
    
    private func setupPaymentMethodPickerScene(
      methods: [PaymentMethod.Model.PaymentMethod],
      completion: (@escaping(_ asset: String) -> Void)
        ) -> UIViewController {
        
        let vc = PaymentMethodPicker.ViewController()
        let sceneModel = PaymentMethodPicker.Model.SceneModel(
            methods: methods
        )
        let amountFormatter = PaymentMethodPicker.AmountFormatter()
        let routing = PaymentMethodPicker.Routing(
            onPaymentMethodPicked: { (asset) in
                completion(asset)
        })
        PaymentMethodPicker.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            amountFormatter: amountFormatter,
            routing: routing
        )
        return vc
    }
}
