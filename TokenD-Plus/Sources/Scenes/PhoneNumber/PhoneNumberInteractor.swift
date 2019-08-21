import Foundation
import RxSwift
import RxCocoa

public protocol PhoneNumberBusinessLogic {
    typealias Event = PhoneNumber.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onNumberEdited(request: Event.NumberEdited.Request)
    func onSetNumberAction(request: Event.SetNumberAction.Request)
}

extension PhoneNumber {
    public typealias BusinessLogic = PhoneNumberBusinessLogic
    
    @objc(PhoneNumberInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = PhoneNumber.Event
        public typealias Model = PhoneNumber.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private var sceneModel: Model.SceneModel
        private let numberValidator: PhoneNumberValidatorProtocol
        private let numberSubmitWorker: PhoneNumberSubmitWorkerProtocol
        private let numberIdentifier: PhoneNumberIdentifierProtocol
        
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            sceneModel: Model.SceneModel,
            numberValidator: PhoneNumberValidatorProtocol,
            numberSubmitWorker: PhoneNumberSubmitWorkerProtocol,
            numberIdentifier: PhoneNumberIdentifierProtocol
            ) {
            
            self.presenter = presenter
            self.sceneModel = sceneModel
            self.numberValidator = numberValidator
            self.numberSubmitWorker = numberSubmitWorker
            self.numberIdentifier = numberIdentifier
        }
        
        // MARK: - Private
        
        private func handleNumberIdentity(identity: PhoneNumberIdentifyResult) {
            let state: Model.NumberState
            switch identity {
                
            case .didNotSet:
                state = .isNotSet
                
            case .number(let number):
                
                self.sceneModel.apiPhoneNumber = String(number.dropFirst())
                self.sceneModel.number = self.sceneModel.apiPhoneNumber
                state = .sameWithIdentity
                
            case .error(let error):
                state = .sameWithIdentity
                break
            }
            let response = Event.SceneUpdated.Response(
                number: self.sceneModel.number,
                state: state
            )
            self.presenter.presentSсeneUpdated(response: response)
        }
        
        private func updateScene() {
            guard let number = self.sceneModel.number else {
                return
            }
            let state: Model.NumberState
            if let apiNumber = self.sceneModel.apiPhoneNumber {
                state = number == apiNumber ? .sameWithIdentity : .updated
            } else {
                state = .isNotSet
            }
            
            let response = Event.SceneUpdated.Response(
                number: self.sceneModel.number,
                state: state
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
    }
}

extension PhoneNumber.Interactor: PhoneNumber.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.observeLoadingStatus()
        self.loadingStatus.accept(.loading)
        self.numberIdentifier.identifyBy(
            accountId: self.sceneModel.accountId,
            completion: { [weak self] (identity) in
                self?.loadingStatus.accept(.loaded)
                self?.handleNumberIdentity(identity: identity)
        })
    }
    
    public func onNumberEdited(request: Event.NumberEdited.Request) {
        self.sceneModel.number = request.number
        self.updateScene()
    }
    
    public func onSetNumberAction(request: Event.SetNumberAction.Request) {
        self.presenter.presentSetNumberAction(response: .loading)
        guard let number = self.sceneModel.number else {
            self.presenter.presentSetNumberAction(response: .error(Model.Error.emptyNumber))
            return
        }
        let finalNumber = "+" + number
        
        guard self.numberValidator.validate(number: finalNumber) else {
            self.presenter.presentSetNumberAction(response: .error(Model.Error.numberIsNotValid))
            return
        }
        
        self.numberSubmitWorker.submitNumber(
            number: finalNumber,
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
}
