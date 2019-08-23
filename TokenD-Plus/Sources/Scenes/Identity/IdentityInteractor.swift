import Foundation
import RxSwift
import RxCocoa

public protocol PhoneNumberBusinessLogic {
    typealias Event = Identity.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onValueEdited(request: Event.ValueEdited.Request)
    func onAction(request: Event.Action.Request)
}

extension Identity {
    public typealias BusinessLogic = PhoneNumberBusinessLogic
    
    @objc(PhoneNumberInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = Identity.Event
        public typealias Model = Identity.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private var sceneModel: Model.SceneModel
        private let numberValidator: PhoneNumberValidatorProtocol?
        private let submitWorker: IdentitySubmitWorkerProtocol
        private let identityIdentifier: IdentityIdentifierProtocol
        
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            sceneModel: Model.SceneModel,
            numberValidator: PhoneNumberValidatorProtocol?,
            submitWorker: IdentitySubmitWorkerProtocol,
            identityIdentifier: IdentityIdentifierProtocol
            ) {
            
            self.presenter = presenter
            self.sceneModel = sceneModel
            self.numberValidator = numberValidator
            self.submitWorker = submitWorker
            self.identityIdentifier = identityIdentifier
        }
        
        // MARK: - Private
        
        private func updateScene() {
            guard let number = self.sceneModel.value else {
                return
            }
            let state: Model.ValueState
            if let apiNumber = self.sceneModel.apiValue {
                state = number == apiNumber ? .sameWithIdentity : .updated
            } else {
                state = .isNotSet
            }
            
            let response = Event.SceneUpdated.Response(
                value: self.sceneModel.value,
                state: state,
                sceneType: self.sceneModel.sceneType
            )
            self.presenter.presentSсeneUpdated(response: response)
        }
        
        private func observeLoadingStatus() {
            self.loadingStatus
                .subscribe(onNext: { [weak self] (status) in
                    self?.presenter.presentLoadingStatusDidChange(response: status)
                })
                .disposed(by: self.disposeBag)
        }
        
        // MARK: - Phone number
        
        private func handleIdentity(identity: IdentifyResult) {
            let state: Model.ValueState
            switch identity {
                
            case .didNotSet:
                state = .isNotSet
                
            case .value(let number):
                
                self.sceneModel.apiValue = String(number.dropFirst())
                self.sceneModel.value = self.sceneModel.apiValue
                state = .sameWithIdentity
                
            case .error(let error):
                let response = Event.Error.Response(error: error)
                self.presenter.presentError(response: response)
                state = .sameWithIdentity
                break
            }
            let response = Event.SceneUpdated.Response(
                value: self.sceneModel.value,
                state: state,
                sceneType: self.sceneModel.sceneType
            )
            self.presenter.presentSсeneUpdated(response: response)
        }
        
        private func handleSetNumberAction() {
            self.presenter.presentSetNumberAction(response: .loading)
            guard let number = self.sceneModel.value else {
                self.presenter.presentSetNumberAction(response: .error(Event.SetNumberAction.Error.emptyNumber))
                return
            }
            let finalNumber = "+" + number
            
            guard let numberValidator = self.numberValidator,
                numberValidator.validate(number: finalNumber) else {
                self.presenter.presentSetNumberAction(response: .error(Event.SetNumberAction.Error.numberIsNotValid))
                return
            }
            
            self.submitWorker.submitIdentity(
                value: finalNumber,
                completion: { [weak self] (result) in
                    self?.presenter.presentSetNumberAction(response: .loaded)
                    let response: Event.SetNumberAction.Response
                    switch result {
                        
                    case .error(let error):
                        response = .error(error)
                        
                    case .success:
                        response = .success
                    }
                    self?.presenter.presentSetNumberAction(response: response)
            })
        }
        
        // MARK: - Telegram
        
        private func handleTelegramAction() {
            
        }
    }
}

extension Identity.Interactor: Identity.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.observeLoadingStatus()
        self.loadingStatus.accept(.loading)
        self.identityIdentifier.identifyBy(
            accountId: self.sceneModel.accountId,
            completion: { [weak self] (identity) in
                self?.loadingStatus.accept(.loaded)
                self?.handleIdentity(identity: identity)
        })
    }
    
    public func onValueEdited(request: Event.ValueEdited.Request) {
        self.sceneModel.value = request.value
        self.updateScene()
    }
    
    public func onAction(request: Event.Action.Request) {
        switch self.sceneModel.sceneType {
            
        case .phoneNumber:
            self.handleSetNumberAction()
            
        case .telegram:
            self.handleTelegramAction()
        }
    }
}
