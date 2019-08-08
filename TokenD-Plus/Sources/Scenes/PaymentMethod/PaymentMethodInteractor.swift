import Foundation
import RxCocoa
import RxSwift

public protocol PaymentMethodBusinessLogic {
    typealias Event = PaymentMethod.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onSelectPaymentMethod(request: Event.SelectPaymentMethod.Request)
    func onPaymentMethodSelected(request: Event.PaymentMethodSelected.Request)
    func onPaymentAction(request: Event.PaymentAction.Request)
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
        private let paymentWorker: PaymentWorkerProtocol
        private var sceneModel: Model.SceneModel
        
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            paymentMethodsFetcher: PaymentMethodsFetcherProtocol,
            paymentWorker: PaymentWorkerProtocol,
            sceneModel: Model.SceneModel
            ) {
            
            self.presenter = presenter
            self.paymentMethodsFetcher = paymentMethodsFetcher
            self.paymentWorker = paymentWorker
            self.sceneModel = sceneModel
        }
        
        // MARK: - Private
        
        private func observeLoadingStatus() {
            self.loadingStatus
                .subscribe(onNext: { [weak self] (status) in
                    self?.presenter.presentLoadingStatusDidChange(response: status)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func updateScene() {
            self.setSelectedMethod()
            let response = Event.ViewDidLoad.Response(
                baseAssetName: self.sceneModel.baseAssetName,
                baseAmount: self.sceneModel.baseAmount,
                selectedMethod: self.sceneModel.selectedPaymentMethod
            )
            self.presenter.presentViewDidLoad(response: response)
        }
        
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
        self.observeLoadingStatus()
        self.loadingStatus.accept(.loading)
        self.paymentMethodsFetcher.fetchPaymentMetods(
            baseAmount: self.sceneModel.baseAmount,
            completion: { [weak self] (methods) in
                self?.loadingStatus.accept(.loaded)
                self?.sceneModel.methods = methods
                self?.updateScene()
        })
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
    
    public func onPaymentAction(request: Event.PaymentAction.Request) {
        guard let selectedPaymentMethod = self.sceneModel.selectedPaymentMethod else {
            return
        }
        self.loadingStatus.accept(.loading)
        self.paymentWorker.performPayment(
            quoteAsset: selectedPaymentMethod.asset,
            quoteAmount: selectedPaymentMethod.amount,
            completion: { [weak self] (result) in
                self?.loadingStatus.accept(.loaded)
                let response: Event.PaymentAction.Response
                switch result {
                    
                case .failure(let error):
                    response = .error(error)
                    
                case .success(let invoce):
                    response = .invoce(invoce)
                }
                self?.presenter.presentPaymentAction(response: response)
            }
        )
    }
}
