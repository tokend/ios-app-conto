import UIKit

public enum AtomicSwap {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension AtomicSwap.Model {
    typealias BaseAmount = Amount
    typealias QuoteAmount = Amount
    
    public struct SceneModel {
        let asset: String
        var asks: [Ask]
    }
    
    public struct Ask {
        let id: String
        let available: BaseAmount
        let prices: [QuoteAmount]
    }
    
    public struct Header {
        let asset: String
    }
    
    public struct Amount {
        let asset: String
        let value: Decimal
    }
    
    public enum Cell {
        case ask(Ask)
        case header(Header)
    }
    
    public enum LoadingStatus {
        case loaded
        case loading
    }
}

// MARK: - Events

extension AtomicSwap.Event {
    public typealias Model = AtomicSwap.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
    }
    
    public enum SceneDidUpdate {
        public enum Response {
            case cells(cells: [Model.Cell])
            case error(Swift.Error)
            case empty
        }
        
        public enum ViewModel {
            case cells(cells: [CellViewAnyModel])
            case empty(String)
        }
    }
    
    public enum RefreshInitiated {
        public struct Request {}
    }
    
    public enum BuyAction {
        public struct Request {
            let id: String
        }
        public struct Response {
            let ask: Model.Ask
        }
        public typealias ViewModel = Response
    }
    
    public enum LoadingStatusDidChange {
        public typealias Request = Model.LoadingStatus
        public typealias Response = Model.LoadingStatus
        public typealias ViewModel = Model.LoadingStatus
    }
}
