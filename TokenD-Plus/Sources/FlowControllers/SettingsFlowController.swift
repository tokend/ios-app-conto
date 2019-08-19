import UIKit
import WebKit
import TokenDSDK

class SettingsFlowController: BaseSignedInFlowController {
    
    // MARK: - Private properties
    
    private let navigationController: NavigationControllerProtocol = NavigationController()
    
    private let onSignOut: () -> Void
    private let onEnvironmentChanged: () -> Void
    
    // MARK: -
    
    init(
        onSignOut: @escaping () -> Void,
        onEnvironmentChanged: @escaping () -> Void,
        appController: AppControllerProtocol,
        flowControllerStack: FlowControllerStack,
        reposController: ReposController,
        managersController: ManagersController,
        userDataProvider: UserDataProviderProtocol,
        keychainDataProvider: KeychainDataProviderProtocol,
        rootNavigation: RootNavigationProtocol
        ) {
        
        self.onSignOut = onSignOut
        self.onEnvironmentChanged = onEnvironmentChanged
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
    
    public func run(showRootScreen: ((_ vc: UIViewController) -> Void)) {
        self.showSettingsScreen(showRootScreen: showRootScreen)
    }
    
    // MARK: - Private
    
    private func showSettingsScreen(showRootScreen: ((_ vc: UIViewController) -> Void)) {
        let vc = self.setupSettings()
        vc.navigationItem.title = Localized(.settings)
        
        self.navigationController.setViewControllers([vc], animated: false)
        showRootScreen(self.navigationController.getViewController())
    }
    
    private func setupSettings() -> UIViewController {
        let vc = Settings.ViewController()
        
        let sectionsProvider = Settings.SettingsSectionsProvider(
            settingsManger: self.flowControllerStack.settingsManager,
            userDataProvider: self.userDataProvider,
            apiConfigurationModel: self.flowControllerStack.apiConfigurationModel,
            tfaApi: self.flowControllerStack.api.tfaApi,
            onPresentAlert: { [weak self] alert in
                self?.navigationController.present(alert, animated: true, completion: nil)
        })
        
        let rounting = Settings.Routing(
            showProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            hideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            }, showShadow: { [weak self] in
                self?.navigationController.showShadow()
            }, hideShadow: { [weak self] in
                self?.navigationController.hideShadow()
            },
               showErrorMessage: { [weak self] errorMessage in
                self?.navigationController.showErrorMessage(errorMessage, completion: nil)
            },
               onCellSelected: { [weak self] (cellIdentifier) in
                self?.switchToSetting(cellIdentifier)
            },
               onShowFees: { [weak self] in
                self?.showFees()
            },
               onShowTerms: { [weak self] (url) in
                self?.showTermsOfService(url: url)
            },
               onSignOut: { [weak self] in
                self?.onSignOut()
        })
        
        let provider = TermsInfoProvider(apiConfigurationModel: self.flowControllerStack.apiConfigurationModel)
        let termsUrl = provider.getTermsUrl()
        let sceneModel = Settings.Model.SceneModel(termsUrl: termsUrl)
        
        Settings.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            sectionsProvider: sectionsProvider,
            routing: rounting
        )
        return vc
    }
    
    private func switchToSetting(_ identifier: Settings.CellIdentifier) {
        switch identifier {
            
        case .accountId:
            let addressManager = ReceiveAddress.ReceiveAddressManager(
                accountId: self.userDataProvider.walletData.accountId,
                email: self.userDataProvider.account
            )
            self.showInfoScreen(title: Localized(.account_capitalized), addressManager: addressManager)
            
        case .seed:
            let addressManager = ReceiveAddress.ExportSeedManager(
                keychainDataProvider: self.keychainDataProvider
            )
            self.showInfoScreen(title: Localized(.secret_seed), addressManager: addressManager)
            
        case .verification:
            self.showVerificationScreen()
            
        case .changePassword:
            self.showChangePasswordScreen()
            
        case .language:
            self.showLanguagesListScene()
            
        case .licenses:
            self.showLicenses()
            
        case .environment:
            self.showEnvironmentListScene()
            
        case .phone:
            self.showPhoneNumberScene()
            
        default:
            break
        }
    }
    
    // MARK: - Settings
    
    private func showInfoScreen(title: String, addressManager: ReceiveAddressManagerProtocol) {
        let vc = ReceiveAddress.ViewController()
        
        let viewConfig = ReceiveAddress.Model.ViewConfig(
            copiedLocalizationKey: Localized(.copied),
            tableViewTopInset: 24,
            headerAppearence: .hidden
        )
        
        let sceneModel = ReceiveAddress.Model.SceneModel()
        
        let qrCodeGenerator = QRCodeGenerator()
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
        
        vc.navigationItem.title = title
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showLanguagesListScene() {
        let vc = self.setupLanguagesListScene()
        vc.navigationItem.title = Localized(.language)
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupLanguagesListScene() -> UIViewController {
        let vc = LanguagesList.ViewController()
        let changeLanguageWorker = LanguagesList.ChangeLanguageWorker()
        let routing = LanguagesList.Routing(
            showError: { [weak self] (message) in
                self?.navigationController.showErrorMessage(
                    message,
                    completion: nil
                )
            }, onLanguageChanged: { [weak self] in
                self?.navigationController.popViewController(true)
        })
        
        LanguagesList.Configurator.configure(
            viewController: vc,
            changeLanguageWorker: changeLanguageWorker,
            routing: routing
        )
        return vc
    }
    
    private func shareItems(_ items: [Any]) {
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.navigationController.present(activity, animated: true, completion: nil)
    }
    
    private func showVerificationScreen() {
        guard let urlString = self.flowControllerStack.apiConfigurationModel.webClient,
            let url = URL(string: urlString) else {
                return
        }
        
        UIApplication.shared.open(
            url,
            options: [:],
            completionHandler: nil
        )
    }
    
    private func showChangePasswordScreen() {
        let vc = self.setupChangePasswordScreen(onSuccess: { [weak self] in
            guard let present = self?.navigationController.getPresentViewControllerClosure() else {
                return
            }
            self?.showSuccessMessage(
                title: Localized(.success),
                message: Localized(.password_has_been_successfully_changed),
                completion: { [weak self] in
                    self?.navigationController.popViewController(true)
                },
                presentViewController: present
            )
        })
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupChangePasswordScreen(onSuccess: @escaping () -> Void) -> UpdatePassword.ViewController {
        let vc = UpdatePassword.ViewController()
        
        let updateRequestBuilder = UpdatePasswordRequestBuilder(
            keyServerApi: self.flowControllerStack.keyServerApi
        )
        let passwordValidator = PasswordValidator()
        let submitPasswordHandler = UpdatePassword.ChangePasswordWorker(
            keyserverApi: self.flowControllerStack.keyServerApi,
            keychainManager: self.managersController.keychainManager,
            userDataManager: self.managersController.userDataManager,
            userDataProvider: self.userDataProvider,
            networkInfoFetcher: self.flowControllerStack.networkInfoFetcher,
            updateRequestBuilder: updateRequestBuilder,
            passwordValidator: passwordValidator
        )
        
        let fields = submitPasswordHandler.getExpectedFields()
        let sceneModel = UpdatePassword.Model.SceneModel(fields: fields)
        
        let routing = UpdatePassword.Routing(
            onShowProgress: { [weak self] in
                self?.navigationController.showProgress()
            },
            onHideProgress: { [weak self] in
                self?.navigationController.hideProgress()
            },
            onShowErrorMessage: { [weak self] (errorMessage) in
                self?.navigationController.showErrorMessage(errorMessage, completion: nil)
            },
            onSubmitSucceeded: {
                onSuccess()
        })
        
        UpdatePassword.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            submitPasswordHandler: submitPasswordHandler,
            routing: routing
        )
        
        vc.navigationItem.title = Localized(.change_password)
        
        return vc
    }
    
    private func showTermsOfService(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func showLicenses() {
        let vc = MarkdownViewer.ViewController()
        
        guard let filePath = Bundle.main.path(
            forResource: "acknowledgements",
            ofType: "markdown"
            ) else {
                return
        }
        
        let routing = MarkdownViewer.Routing()
        
        MarkdownViewer.Configurator.configure(
            viewController: vc,
            filePath: filePath,
            routing: routing
        )
        
        vc.navigationItem.title = Localized(.acknowledgements)
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showFees() {
        let vc = self.setupFees()
        
        vc.navigationItem.title = Localized(.fees)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupFees() -> UIViewController {
        let vc = Fees.ViewController()
        let feesOverviewProvider = Fees.FeesProvider(
            generalApi: self.flowControllerStack.api.generalApi,
            accountId: self.userDataProvider.walletData.accountId
        )
        
        let sceneModel = Fees.Model.SceneModel(
            fees: [],
            selectedAsset: nil,
            target: nil
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
    
    private func showEnvironmentListScene() {
        let vc = self.setupEnvironmentListScene()
        
        vc.navigationItem.title = Localized(.environment)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupEnvironmentListScene() -> UIViewController {
        let vc = EnvironmentsList.ViewController()
        let changeEnvironmentWorker = EnvironmentsList.ChangeEnvironmentWorker()
        let routing = EnvironmentsList.Routing(
            onEnvironmentChanged: { [weak self] in
                self?.onEnvironmentChanged()
            },
            showMessage: { [weak self] (message) in
                guard let present = self?.navigationController.getPresentViewControllerClosure() else {
                    return
                }
                self?.showDialog(
                    title: message,
                    message: nil,
                    style: .alert,
                    options: ["OK"],
                    onSelected: { _ in },
                    onCanceled: nil,
                    presentViewController: present
                )
        })
        EnvironmentsList.Configurator.configure(
            viewController: vc,
            changeEnvironmentWorker: changeEnvironmentWorker,
            routing: routing
        )
        return vc
    }
    
    private func showPhoneNumberScene() {
        let vc = self.setupPhoneNumberScene()
        
        vc.navigationItem.title = Localized(.phone_number)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func setupPhoneNumberScene() -> UIViewController {
        let vc = PhoneNumber.ViewController()
        let sceneModel = PhoneNumber.Model.SceneModel()
        let numberValidator = PhoneNumber.PhoneNumberValidator()
        let numberSubmitWorker = PhoneNumber.PhoneNumberSubmitWorker(
            generalApi: self.flowControllerStack.api.generalApi,
            accountId: self.userDataProvider.walletData.accountId
        )
        let routing = PhoneNumber.Routing(
            showError: { [weak self] (message) in
                self?.navigationController.showErrorMessage(message, completion: nil)
        },
            showMessage: { [weak self] (message) in
                guard let present = self?.navigationController.getPresentViewControllerClosure() else {
                    return
                }
                self?.showSuccessMessage(
                    title: Localized(.success),
                    message: message,
                    completion: nil,
                    presentViewController: present
                )
        },
            showLoading: { [weak self] in
                self?.navigationController.showProgress()
        },
            hideLoading: { [weak self] in
                self?.navigationController.hideProgress()
        })
        
        PhoneNumber.Configurator.configure(
            viewController: vc,
            sceneModel: sceneModel,
            numberValidator: numberValidator,
            numberSubmitWorker: numberSubmitWorker,
            routing: routing
        )
        return vc
    }
}
