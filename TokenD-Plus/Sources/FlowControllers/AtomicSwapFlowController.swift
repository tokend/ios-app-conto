import UIKit
import RxSwift

class AtomicSwapFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol
    private let model: AtomicSwap.Model.Ask
    private let onCompleted: () -> Void
    
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: -
    
    init(
        navigationController: NavigationControllerProtocol,
        model: AtomicSwap.Model.Ask,
        onCompleted: @escaping () -> Void,
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol
        ) {
        
        self.navigationController = navigationController
        self.model = model
        self.onCompleted = onCompleted
        
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
        let vc = self.setupAtomicSwapBuyScreen(ask: self.model)
        
        vc.navigationItem.title = Localized(
            .buy_asset,
            replace: [
                .buy_asset_replace_asset: self.model.available.assetName
            ]
        )
        showRootScreen(vc)
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
    
    private func setupAtomicSwapBuyScreen(ask: AtomicSwap.Model.Ask) -> AtomicSwapBuy.ViewController {
        let vc = AtomicSwapBuy.ViewController()
        
        let sceneModel = AtomicSwapBuy.Model.SceneModel(
            amount: 0,
            selectedQuoteAsset: nil,
            originalAccountId: self.userDataProvider.walletData.accountId,
            ask: ask
        )
        let fiatPaymentSender = AtomicSwapBuy.FiatPaymentSender(
            api: self.flowControllerStack.apiV3.integrationsApi,
            keychainDataProvider: self.keychainDataProvider
        )
        let amountConverter = AmountConverter()
        let atomicSwapPaymentWorker = AtomicSwapBuy.AtomicSwapPaymentWorker(
            accountsApi: self.flowControllerStack.apiV3.accountsApi,
            requestsApi: self.flowControllerStack.apiV3.requetsApi,
            networkFetcher: self.reposController.networkInfoRepo,
            transactionSender: self.managersController.transactionSender,
            amountConverter: amountConverter,
            fiatPaymentSender: fiatPaymentSender,
            ask: ask,
            originalAccountId: self.userDataProvider.walletData.accountId
        )
        
        let amountFormatter = AtomicSwapBuy.AmountFormatter()
        
        let routing = AtomicSwapBuy.Routing(
            onShowProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            onHideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            },
            onShowError: { [weak self] (errorMessage) in
                self?.navigationController.showErrorMessage(errorMessage, completion: nil)
            },
            onPresentPicker: { [weak self] (assets, onSeletced) in
                self?.showAssetPicker(targetAssets: assets, onSelected: onSeletced)
            },
            onAtomicSwapFiatBuyAction: { [weak self] (paymentUrl) in
                self?.showFiatPaymentScene(url: paymentUrl.url)
            },
            onAtomicSwapCryptoBuyAction: { [weak self] (atomicSwapInvoice) in
                self?.showAtomicSwapQrScene(atomicSwapInvoice: atomicSwapInvoice)
            })
        
        AtomicSwapBuy.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            atomicSwapPaymentWorker: atomicSwapPaymentWorker,
            amountFormatter: amountFormatter,
            routing: routing
        )
        
        return vc
    }
    
    private func showFiatPaymentScene(url: URL) {
        let navController = NavigationController()
        let vc = self.setupFiatPaymentScene(
            url: url,
            navController: navController
        )
        vc.navigationItem.title = ""
        
        let doneButton = UIBarButtonItem(
            title: Localized(.done),
            style: .plain,
            target: nil,
            action: nil
        )
        doneButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] (_) in
                self?.reposController.balancesRepo.reloadBalancesDetails()
                vc.dismiss(
                    animated: true,
                    completion: {
                        self?.onCompleted()
                })
            })
            .disposed(by: self.disposeBag)
        
        let backButton = UIBarButtonItem(
            title: Localized(.back),
            style: .plain,
            target: nil,
            action: nil
        )
        backButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { (_) in
                vc.dismiss(
                    animated: true,
                    completion: nil
                )
            })
            .disposed(by: self.disposeBag)
        
        vc.navigationItem.leftBarButtonItem = backButton
        vc.navigationItem.rightBarButtonItem = doneButton
        navController.setViewControllers([vc], animated: false)
        
        self.navigationController.present(
            navController.getViewController(),
            animated: true,
            completion: nil
        )
    }
    
    private func setupFiatPaymentScene(
        url: URL,
        navController: NavigationControllerProtocol
        ) -> UIViewController {
        
        let vc = FiatPayment.ViewController()
        let sceneModel = FiatPayment.Model.SceneModel(
            url: url,
            redirectDomen: self.flowControllerStack.apiConfigurationModel.fiatRedirectDomen
            
        )
        let routing = FiatPayment.Routing(
            showComplete: { [weak self] in
                vc.dismiss(
                    animated: true,
                    completion: {
                        self?.onCompleted()
                })
        },
            showLoading: {
                navController.showProgress()
        },
            hideLoading: {
                navController.hideProgress()
        })
        
        FiatPayment.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            routing: routing
        )
        return vc
    }
    
    private func showAtomicSwapQrScene(
        atomicSwapInvoice: AtomicSwapBuy.Model.AtomicSwapInvoiceViewModel
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
    
    private func showAssetPicker(
        targetAssets: [String],
        onSelected: @escaping(String) -> Void
        ) {
        
        let navigationController = NavigationController()
        let vc = self.setupAssetPicker(
            targetAssets: targetAssets,
            onSelected: onSelected
        )
        vc.navigationItem.title = Localized(.payment_method)
        navigationController.setViewControllers([vc], animated: false)
        self.navigationController
            .getViewController()
            .present(navigationController.getViewController(), animated: true, completion: nil)
    }
    
    private func setupAssetPicker(
        targetAssets: [String],
        onSelected: @escaping(String) -> Void
        ) -> UIViewController {
        
        let vc = AssetPicker.ViewController()
        let assetsFetcher = AssetPicker.AssetsFetcher(
            assetsRepo: self.reposController.assetsRepo,
            imagesUtility: ImagesUtility(storageUrl: self.flowControllerStack.apiConfigurationModel.storageEndpoint),
            targetAssets: targetAssets
        )
        let sceneModel = AssetPicker.Model.SceneModel(
            assets: [],
            filter: nil
        )
        let amountFormatter = AssetPicker.AmountFormatter()
        let routing = AssetPicker.Routing(
            onAssetPicked: { (_, assetName) in
                onSelected(assetName)
        })
        
        AssetPicker.Configurator.configure(
            viewController: vc,
            assetsFetcher: assetsFetcher,
            sceneModel: sceneModel,
            amountFormatter: amountFormatter,
            routing: routing
        )
        return vc
    }
    
    private func shareItems(_ items: [Any]) {
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.navigationController.present(activity, animated: true, completion: nil)
    }
}
