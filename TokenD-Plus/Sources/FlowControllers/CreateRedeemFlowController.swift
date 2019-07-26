import UIKit
import RxSwift

class CreateRedeemFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol
    private let ownerAccountId: String
    private let selectedBalanceId: String?
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: -
    
    init(
        navigationController: NavigationControllerProtocol,
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol,
        ownerAccountId: String,
        selectedBalanceId: String?
        ) {
        
        self.navigationController = navigationController
        self.ownerAccountId = ownerAccountId
        self.selectedBalanceId = selectedBalanceId
        
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
    
    func run(showRootScreen: ((_ vc: UIViewController) -> Void)?) {
        self.showRedeemAmountScene(showRootScreen: showRootScreen)
    }
    
    // MARK: - Private
    
    private func showRedeemAmountScene(showRootScreen: ((_ vc: UIViewController) -> Void)?) {
        let vc = self.setupRedeemAmountScreen()
        
        vc.navigationItem.title = Localized(.redeem)
        if let showRoot = showRootScreen {
            showRoot(vc)
        } else {
            self.rootNavigation.setRootContent(self.navigationController, transition: .fade, animated: false)
        }
    }
    
    private func setupRedeemAmountScreen() -> SendPaymentAmount.ViewController {
        let vc = SendPaymentAmount.ViewController()
        
        let balanceDetailsLoader = SendPaymentAmount.BalanceDetailsLoaderWorker(
            balancesRepo: self.reposController.balancesRepo,
            assetsRepo: self.reposController.assetsRepo,
            operation: .handleRedeem,
            ownerAccountId: self.ownerAccountId
        )
        let amountConverter = AmountConverter()
        let createRedeemRequestWorker = SendPaymentAmount.CreateRedeemRequestWorker(
            assetsRepo: self.reposController.assetsRepo,
            balancesRepo: self.reposController.balancesRepo,
            networkRepo: self.reposController.networkInfoRepo,
            keychainManager: self.managersController.keychainManager,
            amountConverter: amountConverter,
            originalAccountId: self.userDataProvider.walletData.accountId
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
            operation: .handleRedeem
        )
        
        let viewConfig = SendPaymentAmount.Model.ViewConfig.redeemViewConfig()
        
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
            onPresentPicker: { [weak self] (assets, onSelected) in
                self?.showBalancePicker(
                    targetAssets: assets,
                    onSelected: onSelected
                )
            },
            onSendAction: nil,
            onShowWithdrawDestination: nil,
            onShowRedeem: { [weak self] (redeemModel) in
                self?.showRedeemQrScene(redeemModel: redeemModel)
            },
            showFeesOverview: { [weak self] (asset, feeType) in
                self?.showFees(asset: asset, feeType: feeType)
        })
        
        SendPaymentAmount.Configurator.configure(
            viewController: vc,
            senderAccountId: self.userDataProvider.walletData.accountId,
            selectedBalanceId: self.selectedBalanceId,
            sceneModel: sceneModel,
            balanceDetailsLoader: balanceDetailsLoader,
            createRedeemRequestWorker: createRedeemRequestWorker,
            amountFormatter: amountFormatter,
            feeLoader: feeLoaderWorker,
            feeOverviewer: feeOverviewer,
            viewConfig: viewConfig,
            routing: routing
        )
        
        return vc
    }
    
    private func showFees(asset: String, feeType: Int32) {
        let vc = self.setupFees(asset: asset, feeType: feeType)
        
        vc.navigationItem.title = Localized(.fees)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupFees(asset: String, feeType: Int32) -> UIViewController {
        let vc = Fees.ViewController()
        let feesOverviewProvider = Fees.FeesProvider(
            generalApi: self.flowControllerStack.api.generalApi,
            accountId: self.userDataProvider.walletData.accountId
        )
        
        var target: Fees.Model.Target?
        if let systemFeeType = Fees.Model.OperationType(rawValue: feeType) {
            target = Fees.Model.Target(asset: asset, feeType: systemFeeType)
        }
        
        let sceneModel = Fees.Model.SceneModel(
            fees: [],
            selectedAsset: nil,
            target: target
        )
        
        let amountFormatter = Fees.AmountFormatter()
        let feeDataFormatter = Fees.FeeDataFormatter(amountFormatter: amountFormatter)
        
        let routing = Fees.Routing(
            showProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            },
            showMessage: { [weak self] (message) in
                self?.navigationController.showErrorMessage(message, completion: nil)
        })
        
        Fees.Configurator.configure(
            viewController: vc,
            feesOverviewProvider: feesOverviewProvider,
            sceneModel: sceneModel,
            feeDataFormatter: feeDataFormatter,
            routing: routing
        )
        
        return vc
    }
    
    private func showRedeemQrScene(redeemModel: SendPaymentAmount.Model.ShowRedeemViewModel) {
        let vc = ReceiveAddress.ViewController()
        
        let header = Localized(
            .use_this_qr_code_to_redeem,
            replace: [
                .use_this_qr_code_to_redeem_replace_amount: redeemModel.amount
            ]
        )
        let viewConfig = ReceiveAddress.Model.ViewConfig(
            copiedLocalizationKey: Localized(.copied),
            tableViewTopInset: 24,
            headerAppearence: .withText(header)
        )
        
        let sceneModel = ReceiveAddress.Model.SceneModel()
        
        let qrCodeGenerator = QRCodeGenerator()
        let addressManager = ReceiveAddress.RedeemManager(redeem: redeemModel.redeemRequest)
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

    
    // MARK: - Private
    
    private func showBalancePicker(
        targetAssets: [String],
        onSelected: @escaping ((String) -> Void)
        ) {
        
        let navController = NavigationController()
        
        let vc = self.setupBalancePicker(
            targetAssets: targetAssets,
            onSelected: onSelected
        )
        vc.navigationItem.title = Localized(.choose_asset)
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
    
    private func setupBalancePicker(
        targetAssets: [String],
        onSelected: @escaping ((String) -> Void)
        ) -> UIViewController {
        
        let vc = BalancePicker.ViewController()
        let imageUtility = ImagesUtility(
            storageUrl: self.flowControllerStack.apiConfigurationModel.storageEndpoint
        )
        let balancesFetcher = BalancePicker.BalancesFetcher(
            ownerAccountId: self.ownerAccountId,
            balancesRepo: self.reposController.balancesRepo,
            assetsRepo: self.reposController.assetsRepo,
            imagesUtility: imageUtility,
            targetAssets: targetAssets
        )
        let sceneModel = BalancePicker.Model.SceneModel(
            balances: [],
            filter: nil
        )
        let amountFormatter = BalancePicker.AmountFormatter()
        let routing = BalancePicker.Routing(
            onBalancePicked: { (balanceId) in
                onSelected(balanceId)
        })
        
        BalancePicker.Configurator.configure(
            viewController: vc,
            balancesFetcher: balancesFetcher,
            sceneModel: sceneModel,
            amountFormatter: amountFormatter,
            routing: routing
        )
        return vc
    }
}
