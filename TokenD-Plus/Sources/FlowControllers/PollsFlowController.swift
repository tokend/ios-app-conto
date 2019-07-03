import UIKit
import TokenDSDK
import RxSwift

class PollsFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol = NavigationController()
    private let ownerAccountId: String
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: -
    
    init(
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol,
        ownerAccountId: String
        ) {
        
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
    
    public func run(showRootScreen: ((_ vc: UIViewController) -> Void)?) {
        self.showPollsScreen(showRootScreen: showRootScreen)
    }
    
    // MARK: - Private
    
    private func showPollsScreen(showRootScreen: ((_ vc: UIViewController) -> Void)?) {
        let vc = self.setupPollsScene()
        vc.navigationItem.title = Localized(.polls)
        
        self.navigationController.setViewControllers([vc], animated: false)
        
        if let showRootScreen = showRootScreen {
            showRootScreen(self.navigationController.getViewController())
        } else {
            self.rootNavigation.setRootContent(
                self.navigationController,
                transition: .fade,
                animated: false
            )
        }
    }
    
    private func setupPollsScene() -> UIViewController {
        let vc = Polls.ViewController()
        
        let pollsRepo = self.reposController.getPollsRepo(for: self.ownerAccountId)
        let pollsFetcher = Polls.PollsFetcher(pollsRepo: pollsRepo)
        let percentFormatter = Polls.PercentFormatter()
        
        let voterWorker = Polls.VoteWorker(
            transactionSender: self.managersController.transactionSender,
            keychainDataProvider: self.keychainDataProvider,
            userDataProvider: self.userDataProvider,
            networkInfoFetcher: self.reposController.networkInfoRepo
        )
        
        let routing = Polls.Routing(
            showError: { [weak self] (message) in
                self?.navigationController.showErrorMessage(message, completion: nil)
            }, showLoading: { [weak self] in
                self?.navigationController.showProgress()
            }, hideLoading: { [weak self] in
                self?.navigationController.hideProgress()
            }, showShadow: { [weak self] in
                self?.navigationController.showShadow()
            }, hideShadow: { [weak self] in
                self?.navigationController.hideShadow()
        })
        
        Polls.Configurator.configure(
            viewController: vc,
            pollsFetcher: pollsFetcher,
            percentFormatter: percentFormatter,
            voteWorker: voterWorker,
            routing: routing
        )
        
        return vc
    }
}
