import Foundation

public protocol PaymentMethodBusinessLogic {
    typealias Event = PaymentMethod.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onSelectPaymentMethod(request: Event.SelectPaymentMethod.Request)
    func onPaymentMethodSelected(request: Event.PaymentMethodSelected.Request)
}

extension PaymentMethod {
    public typealias BusinessLogic = PaymentMethodBusinessLogic
    
    @objc(PaymentMethodInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = PaymentMethod.Event
        public typealias Model = PaymentMethod.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let paymentMethodsFetcher: PaymentMethodsFetcherProtocol
        private var sceneModel: Model.SceneModel
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            paymentMethodsFetcher: PaymentMethodsFetcherProtocol,
            sceneModel: Model.SceneModel
            ) {
            
            self.presenter = presenter
            self.paymentMethodsFetcher = paymentMethodsFetcher
            self.sceneModel = sceneModel
        }
        
        // MARK: - Private
        
        private func setSelectedMethod() {
            guard let selectedMethod = self.sceneModel.selectedPaymentMethod else {
                self.setFirstMethodSelected()
                return
            }
            
            guard !self.sceneModel.methods.contains(selectedMethod) else {
                return
            }
            self.setFirstMethodSelected()
        }
        
        private func setFirstMethodSelected() {
            self.sceneModel.selectedPaymentMethod = self.sceneModel.methods.first
        }
    }
}

extension PaymentMethod.Interactor: PaymentMethod.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.sceneModel.methods = self.paymentMethodsFetcher.fetchPaymentMetods(
            baseAmount: self.sceneModel.baseAmount
        )
        self.setSelectedMethod()
        let response = Event.ViewDidLoad.Response(
            baseAsset: self.sceneModel.baseAsset,
            baseAmount: self.sceneModel.baseAmount,
            selectedMethod: self.sceneModel.selectedPaymentMethod
        )
        self.presenter.presentViewDidLoad(response: response)
    }
    
    public func onSelectPaymentMethod(request: Event.SelectPaymentMethod.Request) {
        let response = Event.SelectPaymentMethod.Response(methods: self.sceneModel.methods)
        self.presenter.presentSelectPaymentMethod(response: response)
    }
    
    public func onPaymentMethodSelected(request: Event.PaymentMethodSelected.Request) {
        guard let method = self.sceneModel.methods.first(where: { (method) -> Bool in
            return method.asset == request.asset
        }) else {
            return
        }
        self.sceneModel.selectedPaymentMethod = method
        
        let response = Event.PaymentMethodSelected.Response(method: method)
        self.presenter.presentPaymentMethodSelected(response: response)
    }
}
