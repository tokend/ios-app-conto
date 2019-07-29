import Foundation

public protocol AtomicSwapPresentationLogic {
    typealias Event = AtomicSwap.Event
    
    func presentSceneDidUpdate(response: Event.SceneDidUpdate.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
}

extension AtomicSwap {
    public typealias PresentationLogic = AtomicSwapPresentationLogic
    
    @objc(AtomicSwapPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = AtomicSwap.Event
        public typealias Model = AtomicSwap.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        private let amountFormatter: AmountFormatterProtocol
        
        // MARK: -
        
        public init(
            presenterDispatch: PresenterDispatch,
            amountFormatter: AmountFormatterProtocol
            ) {
            
            self.presenterDispatch = presenterDispatch
            self.amountFormatter = amountFormatter
        }
        
        // MARK: - Private
        
        private func getPriceItems(prices: [Model.QuoteAmount]) -> [PriceCell.ViewModel] {
            let pricesViewModels = prices.map { (price) -> PriceCell.ViewModel in
                let amount = self.amountFormatter.formatAmount(
                    price.value,
                    currency: price.asset
                )
                return PriceCell.ViewModel(amount: amount)
            }
            return pricesViewModels
        }
        
        private func getCellViewModels(models: [Model.Cell]) -> [CellViewAnyModel] {
            let cellViewModels = models.map { (model) -> CellViewAnyModel in
                let viewModel: CellViewAnyModel
                switch model {
                    
                case .ask(let ask):
                    let availableAmount = self.amountFormatter.assetAmountToString(ask.available.value)
                    let pricesAmounts = self.getPriceItems(prices: ask.prices)
                    viewModel = AskCell.ViewModel(
                        availableAmount: availableAmount,
                        pricesAmounts: pricesAmounts,
                        baseAsset: ask.available.asset
                    )
                    
                case .header(let header):
                    viewModel = InfoCell.ViewModel(baseAsset: header.asset)
                }
                return viewModel
            }
            return cellViewModels
        }
    }
}

extension AtomicSwap.Presenter: AtomicSwap.PresentationLogic {
    
    public func presentSceneDidUpdate(response: Event.SceneDidUpdate.Response) {
        let viewModel: Event.SceneDidUpdate.ViewModel
        switch response {
            
        case .cells(let cells):
            let cellViewModels = self.getCellViewModels(models: cells)
            viewModel = .cells(cells: cellViewModels)
            
        case .empty:
            viewModel = .empty(Localized(.no_orders))
            
        case .error(let error):
            viewModel = .empty(error.localizedDescription)
        }
        
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displaySceneDidUpdate(viewModel: viewModel)
        }
    }
    
    public func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayLoadingStatusDidChange(viewModel: viewModel)
        }
    }
}
