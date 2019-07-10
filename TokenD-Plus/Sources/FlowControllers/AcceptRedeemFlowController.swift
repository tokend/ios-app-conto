import UIKit
import RxSwift

class AcceptRedeemFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol
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
        rootNavigation: RootNavigationProtocol
        ) {
        
        self.navigationController = navigationController
        
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
        self.presentQRCodeReader(completion: { [weak self] (result) in
            switch result {
            case .canceled:
                break
                
            case .success(let value, _):
                self?.showAcceptRedeemScene(
                    showRootScreen: showRootScreen,
                    request: value
                )
            }
        })
    }
    
    
    // MARK: - Private
    
    private func showAcceptRedeemScene(
        showRootScreen: ((_ vc: UIViewController) -> Void)?,
        request: String
        ) {
        
        let vc = self.setupAcceptRedeemScene(request: request)
        vc.navigationItem.title = Localized(.accept_redeem)
        if let showRoot = showRootScreen {
            showRoot(vc)
        } else {
            self.rootNavigation.setRootContent(self.navigationController, transition: .fade, animated: false)
        }
    }
    
    private func setupAcceptRedeemScene(request: String) -> UIViewController {
        let vc = AcceptRedeem.ViewController()
        let amountFormatter = AcceptRedeem.AmountFormatter()
        let acceptRedeemWorker = AcceptRedeem.AcceptRedeemWorker(
            accountsApiV3: self.flowControllerStack.apiV3.accountsApi,
            networkInfoFetcher: self.reposController.networkInfoRepo,
            amountFormatter: amountFormatter,
            redeemRequest: request
        )
        let routing = AcceptRedeem.Routing(
            showProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            },
            showError: { [weak self] (message) in
                self?.navigationController.showErrorMessage(
                    message,
                    completion: { [weak self] in
                        self?.navigationController.popViewController(true)
                })
            },
            onConfirmRedeem: { [weak self] (redeemModel) in
                self?.showRedeemConfirmationScreen(redeemModel: redeemModel)
        })
        
        AcceptRedeem.Configurator.configure(
            viewController: vc,
            acceptRedeemWorker: acceptRedeemWorker,
            routing: routing
        )
        return vc
    }
    
    private func showRedeemConfirmationScreen(redeemModel: AcceptRedeem.Model.RedeemModel) {
        let vc = self.setupRedeemConfirmationScreen(redeemModel: redeemModel)
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupRedeemConfirmationScreen(
        redeemModel: AcceptRedeem.Model.RedeemModel
        ) -> ConfirmationScene.ViewController {
        
        let vc = ConfirmationScene.ViewController()
        
        let amountFormatter = ConfirmationScene.AmountFormatter()
        let percentFormatter = ConfirmationScene.PercentFormatter()
        let amountConverter = AmountConverter()
        
        let redeemModel = ConfirmationScene.Model.RedeemModel(
            senderAccountId: redeemModel.senderAccountId,
            senderBalanceId: redeemModel.senderBalanceId,
            asset: redeemModel.asset,
            amount: redeemModel.amount,
            salt: redeemModel.salt,
            minTimeBound: redeemModel.minTimeBound,
            maxTimeBound: redeemModel.maxTimeBound,
            hintWrapped: redeemModel.hintWrapped,
            signature: redeemModel.signature
        )
        
        let sectionsProvider = ConfirmationScene.AcceptRedeemConfirmationSectionsProvider(
            redeemModel: redeemModel,
            generalApi: self.flowControllerStack.api.generalApi,
            transactionSender: self.managersController.transactionSender,
            networkInfoFetcher: self.reposController.networkInfoRepo,
            amountFormatter: amountFormatter,
            userDataProvider: userDataProvider,
            amountConverter: amountConverter,
            percentFormatter: percentFormatter,
            originalAccountId: self.userDataProvider.walletData.accountId
        )
        
        let routing = ConfirmationScene.Routing(
            onShowProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            onHideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            },
            onShowError: { [weak self] (errorMessage) in
                self?.navigationController.showErrorMessage(errorMessage, completion: nil)
            },
            onConfirmationSucceeded: { [weak self] in
                self?.navigationController.popViewController(true)
        })
        
        ConfirmationScene.Configurator.configure(
            viewController: vc,
            sectionsProvider: sectionsProvider,
            routing: routing
        )
        
        vc.navigationItem.title = Localized(.confirmation)
        
        return vc
    }
    
    private func presentQRCodeReader(completion: @escaping SendPaymentDestination.QRCodeReaderCompletion) {
        self.runQRCodeReaderFlow(
            presentingViewController: self.navigationController.getViewController(),
            handler: { result in
                switch result {
                    
                case .canceled:
                    completion(.canceled)
                    
                case .success(let value, let metadataType):
                    completion(.success(value: value, metadataType: metadataType))
                }
        })
    }
}
