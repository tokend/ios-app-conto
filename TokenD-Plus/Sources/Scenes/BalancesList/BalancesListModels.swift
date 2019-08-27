import UIKit

public enum BalancesList {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension BalancesList.Model {
    public typealias Ask = AtomicSwap.Model.Ask
    public typealias QuoteAmount = AtomicSwap.Model.QuoteAmount
    public typealias BaseAmount = AtomicSwap.Model.BaseAmount
    
    public struct SceneModel {
        var tabs: [Tab]
        var balances: [Balance]
        var asks: [AskModel]
        var chartBalances: [ChartBalance]
        var selectedChartBalance: ChartBalance?
        var selectedTabIdentifier: TabIdentifier?
        let imageUrl: URL?
        let convertedAsset: String
        let companyName: String
    }
    
    public struct Tab {
        let name: String
        let identifier: TabIdentifier
    }
    
    public struct SectionModel {
        var cells: [CellModel]
    }
    
    public struct SectionViewModel {
        var cells: [CellViewAnyModel]
    }

    public enum CellModel {
        case header(Header)
        case balance(Balance)
        case ask(AskModel)
        case chart(PieChartModel)
    }
    
    public enum TabIdentifier {
        case balances
        case atomicSwapAsks
    }
    
    public enum SceneType {
        case sections(sections: [SectionModel])
        case empty
        case error(Error)
    }
    
    public enum SceneTypeViewModel {
        case sections(sections: [SectionViewModel])
        case empty(String)
    }
    
    public struct ActionModel {
        let title: String
        let image: UIImage
        let actionType: ActionType
    }
    
    public enum ActionType {
        case send
        case receive
        case createRedeem
        case acceptRedeem
    }
    
    public struct LegendCellModel: Equatable {
        let assetName: String
        let balance: Decimal
        let isSelected: Bool
        let balancePercentage: Double
        let balanceType: ChartBalanceType
    }
    
    public struct Header {
        let balance: Decimal
        let asset: String
        let companyName: String
        let imageUrl: URL?
        let cellIdentifier: CellIdentifier
    }
    
    public struct Balance: Equatable {
        let code: String
        let assetName: String
        let iconUrl: URL?
        let balance: Decimal
        let balanceId: String
        let convertedBalance: Decimal
        let cellIdentifier: CellIdentifier
    }
    
    public struct AskModel {
        let ask: Ask
        let imageUrl: URL?
    }
    
    public struct ChartBalance: Equatable {
        let assetName: String
        let balanceId: String
        let convertedBalance: Decimal
        let balancePercentage: Double
        let type: ChartBalanceType
        
        public static func == (lhs: ChartBalance, rhs: ChartBalance) -> Bool {
            return lhs.balanceId == rhs.balanceId
        }
    }
    
    public enum ChartBalanceType {
        case balance
        case other
    }
    
    public struct PieChartEntry {
        let value: Double
    }
    
    public struct PieChartModel {
        let entries: [PieChartEntry]
        let legendCells: [LegendCellModel]
        let highlitedEntry: HighlightedEntryModel?
        let convertAsset: String
    }
    
    public struct PieChartViewModel {
        let entries: [PieChartEntry]
        let highlitedEntry: HighlightedEntryViewModel?
        let colorsPallete: [UIColor]
    }
    
    public struct HighlightedEntryModel {
        let index: Int
        let value: Double
    }
    
    public struct HighlightedEntryViewModel {
        let index: Double
        let value: NSAttributedString
    }
    
    public enum LoadingStatus {
        case loaded
        case loading
    }
    
    public enum ImageRepresentation {
        case image(URL)
        case abbreviation
    }
    
    public enum CellIdentifier {
        case asks
        case balances
        case chart
        case header
    }
}

// MARK: - Events

extension BalancesList.Event {
    public typealias Model = BalancesList.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let tabs: [Model.Tab]
        }
        public struct ViewModel {
            let tabs: [Model.Tab]
        }
    }
    
    public enum SectionsUpdated {
        public struct Response {
            let type: Model.SceneType
            let selectedTabIdentifier: Model.TabIdentifier
            let selectedTabIndex: Int?
        }
        
        public struct ViewModel {
            let type: Model.SceneTypeViewModel
            let selectedTabIdentifier: Model.TabIdentifier
            let selectedTabIndex: Int?
        }
    }
    
    public enum LoadingStatusDidChange {
        public typealias Response = Model.LoadingStatus
        public typealias ViewModel = Response
    }
    
    public enum PieChartEntriesChanged {
        public struct Response {
            let model: Model.PieChartModel
        }
        
        public struct ViewModel {
            let model: Model.PieChartViewModel
        }
    }
    
    public enum PieChartBalanceSelected {
        public struct Request {
            let value: Double
        }
        
        public struct Response {
            let pieChartModel: Model.PieChartModel
            let legendCells: [Model.LegendCellModel]
        }
        
        public struct ViewModel {
            let pieChartViewModel: Model.PieChartViewModel
            let legendCells: [BalancesList.LegendCell.ViewModel]
        }
    }
    
    public enum ActionsDidChange {
        public struct Response {
            let models: [Model.ActionModel]
        }
        public typealias ViewModel = Response
    }
    
    public enum RefreshInitiated {
        public struct Request {}
    }
    
    public enum SelectedTab {
        public struct Request {
            let tabIdentifier: Model.TabIdentifier
        }
    }
    
    public enum BuyAsk {
        public struct Request {
            let id: String
        }
        public struct Response {
            let ask: Model.Ask
        }
        public typealias ViewModel = Response
    }
}
