import UIKit
import RxSwift

class AtomicSwapFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol
    private let assetСode: String
    private let assetName: String
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: -
    
    init(
        navigationController: NavigationControllerProtocol,
        assetСode: String,
        assetName: String,
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol
        ) {
        
        self.navigationController = navigationController
        self.assetСode = assetСode
        self.assetName = assetName
        
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
                .buy_asset_replace_asset: self.assetName
            ]
        )
        showRootScreen(vc)
    }
    
    // MARK: - Private
    
    private func setupAtomicSwapScene() -> UIViewController {
        let vc = AtomicSwap.ViewController()
        let asksRepo = self.reposController.getAtomicSwapAsksRepo(for: self.assetСode)
        let asksFetcher = AtomicSwap.AsksFetcher(
            asksRepo: asksRepo,
            assetsRepo: self.reposController.assetsRepo
        )
        let sceneModel = AtomicSwap.Model.SceneModel(
            assetCode: self.assetСode,
            assetName: self.assetName,
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
                .buy_asset_replace_asset: ask.available.assetName
            ]
        )
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupAtomicSwapBuyScreen(ask: AtomicSwap.Model.Ask) -> SendPaymentAmount.ViewController {
        let vc = SendPaymentAmount.ViewController()
        
        let buyPreposition = SendPaymentAmount.Model.BalanceDetails(
            assetCode: ask.available.assetCode,
            assetName: ask.available.assetName,
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
        vc.navigationItem.title = Localized(.payment_method)
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupPaymentMethodScene(askModel: SendPaymentAmount.Model.AskModel) -> UIViewController {
        let vc = PaymentMethod.ViewController()
        
        let paymentMethodsFetcher = PaymentMethod.AtomicSwapAsksPaymentMethodsFetcher(
            networkFecther: self.reposController.networkInfoRepo,
            quoteAssets: askModel.ask.prices
        )
        let fiatPaymentSender = PaymentMethod.FiatPaymentSender()
        let amountConverter = AmountConverter()
        
        let paymentWorker = PaymentMethod.AtomicSwapPaymentWorker(
            accountsApi: self.flowControllerStack.apiV3.accountsApi,
            requestsApi: self.flowControllerStack.apiV3.requetsApi,
            networkFetcher: self.reposController.networkInfoRepo,
            transactionSender: self.managersController.transactionSender,
            amountConverter: amountConverter,
            fiatPaymentSender: fiatPaymentSender,
            askModel: askModel,
            originalAccountId: self.userDataProvider.walletData.accountId
        )
        
        let sceneModel = PaymentMethod.Model.SceneModel(
            baseAssetCode: askModel.ask.available.assetCode,
            baseAssetName: askModel.ask.available.assetName,
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
            }, showAtomicSwapInvoice: { [weak self] (paymentUrl) in
                self?.showFiatPaymentScene(url: paymentUrl.url)
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
    
    private func showFiatPaymentScene(url: URL) {
        let vc = self.setupFiatPaymentScene(url: url)
        vc.navigationItem.title = ""
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupFiatPaymentScene(url: URL) -> UIViewController {
        let vc = FiatPayment.ViewController()
        let sceneModel = FiatPayment.Model.SceneModel(url: url)
        let routing = FiatPayment.Routing()
        
        FiatPayment.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            routing: routing
        )
        return vc
    }
    
    private func showAtomicSwapQrScene(
        atomicSwapInvoice: PaymentMethod.Model.AtomicSwapInvoiceViewModel
        ) {
        
        let vc = ReceiveAddress.ViewController()
        
        let header = Localized(
            .send_to_this_address,
            replace: [
                .send_to_this_address_replace_amount: atomicSwapInvoice.amount
            ]
        )
        let viewConfig = ReceiveAddress.Model.ViewConfig(
            copiedLocalizationKey: Localized(.copied),
            tableViewTopInset: 24,
            headerAppearence: .withText(header),
            qrValueAppearence: .hidden
        )
        
        let sceneModel = ReceiveAddress.Model.SceneModel()
        
        let qrCodeGenerator = QRCodeGenerator()
        let addressManager = ReceiveAddress.AtomicSwapManager(
            address: atomicSwapInvoice.address
        )
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
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func shareItems(_ items: [Any]) {
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.navigationController.present(activity, animated: true, completion: nil)
    }
}
