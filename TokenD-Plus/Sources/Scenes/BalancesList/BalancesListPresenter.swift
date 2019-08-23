import UIKit

public protocol BalancesListPresentationLogic {
    typealias Event = BalancesList.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
    func presentSectionsUpdated(response: Event.SectionsUpdated.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
    func presentPieChartEntriesChanged(response: Event.PieChartEntriesChanged.Response)
    func presentPieChartBalanceSelected(response: Event.PieChartBalanceSelected.Response)
    func presentActionsDidChange(response: Event.ActionsDidChange.Response)
    func presentBuyAsk(response: Event.BuyAsk.Response)
}

extension BalancesList {
    public typealias PresentationLogic = BalancesListPresentationLogic
    
    @objc(BalancesListPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = BalancesList.Event
        public typealias Model = BalancesList.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        private let amountFormatter: AmountFormatterProtocol
        private let percentFormatter: PercentFormatterProtocol
        private let colorsProvider: PieChartColorsProviderProtocol
        
        // MARK: -
        
        init(
            presenterDispatch: PresenterDispatch,
            amountFormatter: AmountFormatterProtocol,
            percentFormatter: PercentFormatterProtocol,
            colorsProvider: PieChartColorsProviderProtocol
            ) {
            
            self.presenterDispatch = presenterDispatch
            self.amountFormatter = amountFormatter
            self.percentFormatter = percentFormatter
            self.colorsProvider = colorsProvider
        }
        
        // MARK: - Private
        
        private func getChartViewModel(model: Model.PieChartModel) -> Model.PieChartViewModel {
            var highlightedEntry: Model.HighlightedEntryViewModel?
            if let highlightedEntryModel = model.highlitedEntry {
                let percent = self.percentFormatter.formatPercantage(
                    percent: highlightedEntryModel.value
                )
                highlightedEntry = Model.HighlightedEntryViewModel(
                    index: Double(highlightedEntryModel.index),
                    value: NSAttributedString(string: percent)
                )
            }
            let colorsPallete = self.colorsProvider.getDefaultPieChartColors()
            
            return Model.PieChartViewModel(
                entries: model.entries,
                highlitedEntry: highlightedEntry,
                colorsPallete: colorsPallete
            )
        }
        
        private func getLegendCellViewModels(
            cells: [Model.LegendCellModel],
            convertedAsset: String
            ) -> [LegendCell.ViewModel] {
            
            let cellViewModels = cells.map { (cell) -> LegendCell.ViewModel in
                var assetName: String
                var indicatorColor: UIColor = Theme.Colors.contentBackgroundColor
                switch cell.balanceType {
                    
                case .balance:
                    assetName = cell.assetName
                    
                case .other:
                    assetName = Localized(.other)
                    indicatorColor = self.colorsProvider.getPieChartColorForOther()
                }
                
                let balance = self.amountFormatter.formatAmount(
                    cell.balance,
                    currency: convertedAsset
                )
                
                if let cellIndex = cells.indexOf(cell) {
                    let colorsPallete = self.colorsProvider.getDefaultPieChartColors()
                    indicatorColor = colorsPallete[cellIndex]
                }
                
                return LegendCell.ViewModel(
                    assetName: assetName,
                    balance: balance,
                    isSelected: cell.isSelected,
                    indicatorColor: indicatorColor,
                    percentageValue: cell.balancePercentage
                )
            }
            return cellViewModels
        }
        
        private func getSectionViewModels(sections: [Model.SectionModel]) -> [Model.SectionViewModel] {
            let sectionsViewModels = sections.map { (section) -> Model.SectionViewModel in
                let cells = section.cells.map({ (cell) -> CellViewAnyModel in
                    switch cell {
                        
                    case .balance(let balanceModel):
                        let balance = self.amountFormatter.assetAmountToString(balanceModel.balance)
                        let balanceToShow = Localized(
                            .available_amount,
                            replace: [
                                .available_amount_replace_amount: balance
                            ]
                        )
                        
                        let abbreviationBackgroundColor = TokenColoringProvider.shared.coloringForCode(balanceModel.assetName)
                        let abbreviation = balanceModel.assetName.first
                        let abbreviationText = abbreviation?.description ?? ""
                        
                        var imageRepresentation = Model.ImageRepresentation.abbreviation
                        if let url = balanceModel.iconUrl {
                            imageRepresentation = .image(url)
                        }
                        let balanceViewModel = BalancesList.BalanceCell.ViewModel(
                            assetName: balanceModel.assetName,
                            imageRepresentation: imageRepresentation,
                            balance: balanceToShow,
                            abbreviationBackgroundColor: abbreviationBackgroundColor,
                            abbreviationText: abbreviationText,
                            balanceId: balanceModel.balanceId,
                            cellIdentifier: .balances
                        )
                        return balanceViewModel
                        
                    case .header(let headerModel):
                        let balanceTitle = self.amountFormatter.formatAmount(
                            headerModel.balance,
                            currency: headerModel.asset
                        )
                        let abbreviationText: String
                        if let firstLetter = headerModel.companyName.first {
                            abbreviationText = "\(firstLetter)"
                        } else {
                            abbreviationText = "D"
                        }
                        let abbreviationColor = TokenColoringProvider.shared.coloringForCode(headerModel.companyName)
                        let headerModel = BalancesList.HeaderCell.ViewModel(
                            imageUrl: headerModel.imageUrl,
                            abbreviationСolor: abbreviationColor,
                            abbreviationText: abbreviationText,
                            balance: balanceTitle,
                            cellIdentifier: .header
                        )
                        return headerModel
                        
                    case .chart(let pieChartModel):
                        let pieChartViewModel = self.getChartViewModel(model: pieChartModel)
                        let legendCells = self.getLegendCellViewModels(
                            cells: pieChartModel.legendCells,
                            convertedAsset: pieChartModel.convertAsset
                        )
                        let chartViewModel = BalancesList.PieChartCell.ViewModel(
                            chartViewModel: pieChartViewModel,
                            legendCells: legendCells,
                            cellIdentifier: .chart
                        )
                        return chartViewModel
                        
                    case .ask(let askModel):
                        let priceAmount = self.amountFormatter.formatAmount(
                            askModel.ask.prices.first?.value ?? 0,
                            currency: askModel.ask.prices.first?.assetName ?? ""
                        )
                        let price = "\(Localized(.price_colon)) \(priceAmount)"
                        let availableAmount = self.amountFormatter.formatAmount(
                            askModel.ask.available.value,
                            currency: askModel.ask.available.assetName
                        )
                        let available = "\(Localized(.available_colon)) \(availableAmount)"
                        let abbreviationText: String
                        if let firstLetter = askModel.ask.available.assetName.first {
                            abbreviationText = "\(firstLetter)"
                        } else {
                            abbreviationText = "D"
                        }
                        let abbreviationColor = TokenColoringProvider.shared.coloringForCode(askModel.ask.available.assetName)
                        var imageRepresentation: Model.ImageRepresentation = .abbreviation
                        if let url = askModel.imageUrl {
                            imageRepresentation = .image(url)
                        }
                        
                        let askViewModel = AskCell.ViewModel(
                            askId: askModel.ask.id,
                            assetName: askModel.ask.available.assetName,
                            imageRepresentation: imageRepresentation,
                            price: price,
                            available: available,
                            abbreviationBackgroundColor: abbreviationColor,
                            abbreviationText: abbreviationText,
                            cellIdentifier: .asks
                        )
                        return askViewModel
                    }
                })
                return Model.SectionViewModel(cells: cells)
            }
            return sectionsViewModels
        }
    }
}

extension BalancesList.Presenter: BalancesList.PresentationLogic {
    
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let viewModel = Event.ViewDidLoad.ViewModel(tabs: response.tabs)
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
    
    public func presentSectionsUpdated(response: Event.SectionsUpdated.Response) {
        let type: Model.SceneTypeViewModel
        switch response.type {
            
        case .empty:
            switch response.selectedTabIdentifier {
                
            case .atomicSwapAsks:
                type = .empty(Localized(.no_asks))
                
            case .balances:
                type = .empty(Localized(.no_balances))
            }
            
        case .error(let error):
            type = .empty(error.localizedDescription)
            
        case .sections(let sections):
            let sectionsViewModels = self.getSectionViewModels(sections: sections)
            type = .sections(sections: sectionsViewModels)
        }
        
        let viewModel = Event.SectionsUpdated.ViewModel(
            type: type,
            selectedTabIdentifier: response.selectedTabIdentifier,
            selectedTabIndex: response.selectedTabIndex
        )
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displaySectionsUpdated(viewModel: viewModel)
        }
    }
    
    public func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayLoadingStatusDidChange(viewModel: viewModel)
        }
    }
    
    public func presentPieChartEntriesChanged(response: Event.PieChartEntriesChanged.Response) {
        var highlightedEntry: Model.HighlightedEntryViewModel?
        if let highLightedEntryModel = response.model.highlitedEntry {
            let value = highLightedEntryModel.value.rounded()
            let string = "\(Int(value))%"
            highlightedEntry = Model.HighlightedEntryViewModel(
                index: Double(highLightedEntryModel.index),
                value: NSAttributedString(string: string)
            )
        }
        let colorsPallete = self.colorsProvider.getDefaultPieChartColors()
        
        let model = Model.PieChartViewModel(
            entries: response.model.entries,
            highlitedEntry: highlightedEntry,
            colorsPallete: colorsPallete
        )
        let viewModel = Event.PieChartEntriesChanged.ViewModel(model: model)
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayPieChartEntriesChanged(viewModel: viewModel)
        }
    }
    
    public func presentPieChartBalanceSelected(response: Event.PieChartBalanceSelected.Response) {
        let pieChartViewModel = self.getChartViewModel(model: response.pieChartModel)
        let legendCells = self.getLegendCellViewModels(
            cells: response.legendCells,
            convertedAsset: response.pieChartModel.convertAsset
        )
        let viewModel = Event.PieChartBalanceSelected.ViewModel(
            pieChartViewModel: pieChartViewModel,
            legendCells: legendCells
        )
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayPieChartBalanceSelected(viewModel: viewModel)
        }
    }
    
    public func presentActionsDidChange(response: Event.ActionsDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayActionsDidChange(viewModel: viewModel)
        }
    }
    
    public func presentBuyAsk(response: Event.BuyAsk.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayBuyAsk(viewModel: viewModel)
        }
    }
}
