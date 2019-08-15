import Foundation

public protocol KYCBusinessLogic {
    typealias Event = KYC.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onTextFieldValueDidChange(request: Event.TextFieldValueDidChange.Request)
    func onAction(request: Event.Action.Request)
}

extension KYC {
    public typealias BusinessLogic = KYCBusinessLogic
    
    @objc(KYCInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = KYC.Event
        public typealias Model = KYC.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let kycForSender: KYCFormSenderProtocol
        private let kycVerificationChecker: KYCVerificationCheckerProtocol
        private var sceneModel: Model.SceneModel
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            kycForSender: KYCFormSenderProtocol,
            kycVerificationChecker: KYCVerificationCheckerProtocol
            ) {
            
            self.presenter = presenter
            self.kycForSender = kycForSender
            self.kycVerificationChecker = kycVerificationChecker
            self.sceneModel = Model.SceneModel(fields: [])
        }
        
        // MARK: - Private
        
        private func setupScene() {
            let fields: [Model.Field] = [
                Model.Field(type: .name, value: nil),
                Model.Field(type: .surname, value: nil),
            ]
            self.sceneModel.fields = fields
            let response = Event.ViewDidLoad.Response(fields: fields)
            self.presenter.presentViewDidLoad(response: response)
        }
        
        private func handleFieldEditing(fieldType: Model.FieldType, value: String?) {
            guard let index = self.sceneModel.fields.firstIndex(where: { (field) -> Bool in
                return field.type == fieldType
            }) else {
                return
            }
            
            var field = self.sceneModel.fields[index]
            field.value = value
            self.sceneModel.fields[index] = field
        }
        
        private func getFieldValue(fieldType: Model.FieldType) -> String? {
            let field = self.sceneModel.fields.first(where: { (field) in
                return field.type == fieldType
            })
            return field?.value
        }
        
        private func startVerificationCheck() {
            self.kycVerificationChecker
                .startToCheck(completion: { [weak self] (result) in
                    switch result {
                    case .verified:
                        let response = Event.KYCApproved.Response()
                        self?.presenter.presentKYCApproved(response: response)
                    }
            })
        }
    }
}

extension KYC.Interactor: KYC.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.setupScene()
    }
    
    public func onTextFieldValueDidChange(request: Event.TextFieldValueDidChange.Request) {
        self.handleFieldEditing(
            fieldType: request.fieldType,
            value: request.text
        )
    }
    
    public func onAction(request: Event.Action.Request) {
        self.presenter.presentAction(response: .loading)
        guard let name = self.getFieldValue(fieldType: .name),
            !name.isEmpty else {
                self.presenter.presentAction(response: .validationError(.emptyName))
                return
        }
        
        guard let surname = self.getFieldValue(fieldType: .surname),
            !surname.isEmpty else {
                self.presenter.presentAction(response: .validationError(.emptySurname))
                return
        }
        
        self.kycForSender.submitKYCRequest(
            name: name,
            surname: surname,
            completion: { [weak self] (result) in
                self?.presenter.presentAction(response: .loaded)
                let  response: Event.Action.Response
                switch result {
                    
                case .error(let error):
                    response = .failure(error)
                    
                case .success:
                    response = .success
                    self?.startVerificationCheck()
                }
                self?.presenter.presentAction(response: response)
            }
        )
    }
}
