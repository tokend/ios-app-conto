import Foundation

public protocol PhoneNumberBusinessLogic {
    typealias Event = PhoneNumber.Event
    
    func onNumberEdited(request: Event.NumberEdited.Request)
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
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            sceneModel: Model.SceneModel
            ) {
            
            self.presenter = presenter
            self.sceneModel = sceneModel
        }
    }
}

extension PhoneNumber.Interactor: PhoneNumber.BusinessLogic {
    
    public func onNumberEdited(request: Event.NumberEdited.Request) {
        self.sceneModel.number = request.number
    }
}
