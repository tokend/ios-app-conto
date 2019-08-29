import Foundation
import RxSwift
import RxCocoa
import TokenDWallet

protocol AtomicSwapBuyBusinessLogic {
    
    typealias Event = AtomicSwapBuy.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onSelectQuoteAsset(request: Event.SelectQuoteAsset.Request)
    func onQuoteAssetSelected(request: Event.QuoteAssetSelected.Request)
    func onEditAmount(request: Event.EditAmount.Request)
    func onAtomicSwapBuyAction(request: Event.AtomicSwapBuyAction.Request)
}

extension AtomicSwapBuy {
    typealias BusinessLogic = AtomicSwapBuyBusinessLogic
    
    class Interactor {
        
        typealias Model = AtomicSwapBuy.Model
        typealias Event = AtomicSwapBuy.Event
        
        private let presenter: PresentationLogic
        private let queue: DispatchQueue
        private var sceneModel: Model.SceneModel
        private let atomicSwapPaymentWorker: AtomicSwapPaymentWorkerProtocol
        
        private let disposeBag = DisposeBag()
        
        init(
            presenter: PresentationLogic,
            queue: DispatchQueue,
            sceneModel: Model.SceneModel,
            atomicSwapPaymentWorker: AtomicSwapPaymentWorkerProtocol
            ) {
            
            self.presenter = presenter
            self.queue = queue
            self.sceneModel = sceneModel
            self.atomicSwapPaymentWorker = atomicSwapPaymentWorker
        }
        
        // MARK: - Private
        
        private func checkAmountValid() -> Bool {
            let amount = self.sceneModel.amount
            let isValid = amount <= self.sceneModel.ask.available.value
            
            return isValid
        }
        
        private func getQuoteAssetNames() -> [Model.QuoteAsset] {
            return self.sceneModel.ask.prices.map { (price) -> Model.QuoteAsset in
                return price.assetName
            }
        }
        
        private func updateSelectedQuoteAsset() {
            self.sceneModel.selectedQuoteAsset = self.getQuoteAssetNames().first
        }
        
        // MARK: - Send
        
        private func handleAtomicSwapBuy() {
            self.presenter.presentAtomicSwapBuyAction(response: .loading)
            guard self.sceneModel.amount > 0 else {
                self.presenter.presentAtomicSwapBuyAction(response: .failed(.emptyAmount))
                return
            }
            
            let amount = self.sceneModel.amount
            guard self.sceneModel.ask.available.value >= amount else {
                self.presenter.presentAtomicSwapBuyAction(response: .failed(.bidMoreThanAsk))
                return
            }
            guard let quoteAsset = self.sceneModel.selectedQuoteAsset else {
                self.presenter.presentAtomicSwapBuyAction(response: .failed(.failedToBuildTransaction))
                return

            }
            self.atomicSwapPaymentWorker.performPayment(
                baseAmount: amount,
                quoteAsset: quoteAsset,
                completion: { [weak self] (result) in
                    self?.presenter.presentAtomicSwapBuyAction(response: .loaded)
                    let response: Event.AtomicSwapBuyAction.Response
                    switch result {
                        
                    case .failure(let error):
                        response = .failed(error)
                        
                    case .success(let paymentType):
                        response = .succeeded(paymentType)
                    }
                    self?.presenter.presentAtomicSwapBuyAction(response: response)
            })
        }
    }
}

// MARK: - BusinessLogic

extension AtomicSwapBuy.Interactor: AtomicSwapBuy.BusinessLogic {
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.updateSelectedQuoteAsset()
        let response = Event.ViewDidLoad.Response(
            availableAmount: self.sceneModel.ask.available.value,
            baseAsset: self.sceneModel.ask.available.assetName,
            selectedQuoteAsset: self.sceneModel.selectedQuoteAsset ?? ""
        )
        self.presenter.presentViewDidLoad(response: response)
    }
    
    func onSelectQuoteAsset(request: Event.SelectQuoteAsset.Request) {
        let quoteAssets = self.getQuoteAssetNames()
        let response = Event.SelectQuoteAsset.Response(quoteAssets: quoteAssets)
        self.presenter.presentSelectQuoteAsset(response: response)
    }
    
    func onQuoteAssetSelected(request: Event.QuoteAssetSelected.Request) {
        self.sceneModel.selectedQuoteAsset = request.asset
        let response = Event.QuoteAssetSelected.Response(asset: request.asset)
        self.presenter.presentQuoteAssetSelected(response: response)
    }
    
    func onEditAmount(request: Event.EditAmount.Request) {
        self.sceneModel.amount = request.amount
        
        let response = Event.EditAmount.Response(amountValid: self.checkAmountValid())
        self.presenter.presentEditAmount(response: response)
    }
    
    public func onAtomicSwapBuyAction(request: Event.AtomicSwapBuyAction.Request) {
        self.handleAtomicSwapBuy()
    }
}
