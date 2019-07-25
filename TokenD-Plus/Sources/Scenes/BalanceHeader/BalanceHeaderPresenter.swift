import Foundation

public protocol BalanceHeaderPresentationLogic {
    typealias Event = BalanceHeader.Event
    
    func presentBalanceUpdated(response: Event.BalanceUpdated.Response)
}

extension BalanceHeader {
    public typealias PresentationLogic = BalanceHeaderPresentationLogic
    
    @objc(BalanceHeaderPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = BalanceHeader.Event
        public typealias Model = BalanceHeader.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        private let amountFormatter: AmountFormatterProtocol
        
        // MARK: -
        
        init(
            presenterDispatch: PresenterDispatch,
            amountFormatter: AmountFormatterProtocol
            ) {
            
            self.presenterDispatch = presenterDispatch
            self.amountFormatter = amountFormatter
        }
    }
}

extension BalanceHeader.Presenter: BalanceHeader.PresentationLogic {
    
    public func presentBalanceUpdated(response: Event.BalanceUpdated.Response) {
        let balance = self.amountFormatter.assetAmountToString(response.balanceAmount.value)
        var imageRepresentation: Model.ImageRepresentation
        
        if let url = response.iconUrl {
            imageRepresentation = .image(url)
        } else {
            let abbreviationColor = TokenColoringProvider
                .shared
                .coloringForCode(response.balanceAmount.assetName)
            
            let abbreviationCode = response.balanceAmount.assetName.first?.description ?? ""
            imageRepresentation = .abbreviation(
                text: abbreviationCode,
                color: abbreviationColor
            )
        }
        let title = "\(response.balanceAmount.assetName)\n\(balance)"
        let viewModel = Event.BalanceUpdated.ViewModel(
            assetName: response.balanceAmount.assetName,
            balance: balance,
            title: title,
            imageRepresentation: imageRepresentation
        )
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayBalanceUpdated(viewModel: viewModel)
        }
    }
}
