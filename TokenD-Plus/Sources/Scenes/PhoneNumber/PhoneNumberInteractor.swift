import Foundation

public protocol PhoneNumberBusinessLogic {
    typealias Event = PhoneNumber.Event
    
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
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            sceneModel: Model.SceneModel,
            numberValidator: PhoneNumberValidatorProtocol,
            numberSubmitWorker: PhoneNumberSubmitWorkerProtocol
            ) {
            
            self.presenter = presenter
            self.sceneModel = sceneModel
            self.numberValidator = numberValidator
            self.numberSubmitWorker = numberSubmitWorker
        }
    }
}

extension PhoneNumber.Interactor: PhoneNumber.BusinessLogic {
    
    public func onNumberEdited(request: Event.NumberEdited.Request) {
        self.sceneModel.number = request.number
    }
    
    public func onSetNumberAction(request: Event.SetNumberAction.Request) {
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
