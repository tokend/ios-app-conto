import Foundation

public protocol PaymentMethodPickerBusinessLogic {
    typealias Event = PaymentMethodPicker.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
}

extension PaymentMethodPicker {
    public typealias BusinessLogic = PaymentMethodPickerBusinessLogic
    
    @objc(PaymentMethodPickerInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = PaymentMethodPicker.Event
        public typealias Model = PaymentMethodPicker.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let sceneModel: Model.SceneModel
        
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

extension PaymentMethodPicker.Interactor: PaymentMethodPicker.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        let response = Event.ViewDidLoad.Response(
            methods: self.sceneModel.methods
        )
        self.presenter.presentViewDidLoad(response: response)
    }
}
