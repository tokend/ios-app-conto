import UIKit
import RxSwift

class FacilitiesFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let ownerAccountId: String
    private var backToCompanies: (() -> Void)
    private var onSignOut: (() -> Void)
    
    // MARK: -
    
    init(
        navigationController: NavigationControllerProtocol,
        ownerAccountId: String,
        backToCompanies: @escaping (() -> Void),
        onSignOut: @escaping (() -> Void),
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
        self.backToCompanies = backToCompanies
        self.onSignOut = onSignOut
        
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
    
    func run(showRootScreen: ((_ vc: UIViewController) -> Void)) {
        self.showFacilitiesScene(showRootScreen: showRootScreen)
    }
    
    // MARK: - Private
    
    private func showFacilitiesScene(showRootScreen: ((_ vc: UIViewController) -> Void)) {
        let vc = self.setupFacilitiesScene()
        vc.navigationItem.title = Localized(.other)
        
        showRootScreen(vc)
    }
    
    private func setupFacilitiesScene() -> UIViewController {
        let vc = FacilitiesList.ViewController()
        let sceneModel = FacilitiesList.Model.SceneModel(
            originalAccountId: self.userDataProvider.walletData.accountId,
            ownerAccountId: self.ownerAccountId
        )
        let routing = FacilitiesList.Routing(
            showSettings: { [weak self] in
                guard let navigationController = self?.navigationController else {
                    return
                }
                self?.runSettingsFlow(navigationController: navigationController)
            },
            showCompanies: { [weak self] in
                self?.backToCompanies()
        })
        FacilitiesList.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            routing: routing
        )
        return vc
    }
    
    private func runSettingsFlow(navigationController: NavigationControllerProtocol) {
        let settingsflow = SettingsFlowController(
            onSignOut: self.onSignOut,
            appController: self.appController,
            flowControllerStack: self.flowControllerStack,
            reposController: self.reposController,
            managersController: self.managersController,
            userDataProvider: self.userDataProvider,
            keychainDataProvider: self.keychainDataProvider,
            rootNavigation: self.rootNavigation
        )
        self.currentFlowController = settingsflow
        settingsflow.run(showRootScreen: { (vc) in
            navigationController.pushViewController(vc, animated: true)
        })
    }
}
