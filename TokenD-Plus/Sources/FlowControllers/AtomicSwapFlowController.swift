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
        })
        
        AtomicSwap.Configurator.configure(
            viewController: vc,
            amountFormatter: amountFormatter,
            routing: routing
        )
        
        return vc
    }
    
}
