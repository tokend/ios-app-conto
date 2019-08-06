import Foundation

public protocol FiatPaymentBusinessLogic {
    typealias Event = FiatPayment.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
}

extension FiatPayment {
    public typealias BusinessLogic = FiatPaymentBusinessLogic
    
    @objc(FiatPaymentInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = FiatPayment.Event
        public typealias Model = FiatPayment.Model
        
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

extension FiatPayment.Interactor: FiatPayment.BusinessLogic {
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        let response = Event.ViewDidLoad.Response(
            amount: self.sceneModel.amount,
            asset: self.sceneModel.asset
        )
        self.presenter.presentViewDidLoad(response: response)
    }
}
