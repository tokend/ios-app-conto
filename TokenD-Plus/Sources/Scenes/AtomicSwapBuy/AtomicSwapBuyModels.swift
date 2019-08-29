import Foundation

public enum AtomicSwapBuy {
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

public extension AtomicSwapBuy.Model {
    typealias Ask = AtomicSwap.Model.Ask
    typealias QuoteAsset = String
    
    struct SceneModel {
        public var amount: Decimal = 0.0
        public var selectedQuoteAsset: String?
        public let originalAccountId: String
        public let ask: Ask
    }
    
    struct AskModel {
        let ask: Ask
        let amount: Decimal
    }
    
    enum AtomicSwapPaymentType {
        case fiat(AtomicSwapPaymentUrl)
        case crypto(AtomicSwapInvoiceModel)
    }
    
    enum AtomicSwapPaymentViewType {
        case fiat(AtomicSwapPaymentUrl)
        case crypto(AtomicSwapInvoiceViewModel)
    }
    
    struct AtomicSwapPaymentUrl {
        let url: URL
    }
    
    struct AtomicSwapInvoiceModel {
        let address: String
        let asset: String
        let amount: Decimal
    }
    
    struct AtomicSwapInvoiceViewModel {
        let address: String
        let amount: String
    }
}

// MARK: - Events

extension AtomicSwapBuy.Event {
    
    public typealias Model = AtomicSwapBuy.Model
    
    struct ViewDidLoad {
        struct Request {}
        
        struct Response {
            let availableAmount: Decimal
            let baseAsset: String
            let selectedQuoteAsset: Model.QuoteAsset
        }
        
        struct ViewModel {
            let availableAmount: String
            let availableAsset: String
            let selectedQuoteAsset: Model.QuoteAsset
        }
    }
    
    struct SelectQuoteAsset {
        struct Request {}
        
        struct Response {
            let quoteAssets: [Model.QuoteAsset]
        }
        
        struct ViewModel {
            let quoteAssets: [Model.QuoteAsset]
        }
    }
    
    struct QuoteAssetSelected {
        struct Request {
            let asset: Model.QuoteAsset
        }
        typealias Response = Request
        typealias ViewModel = Request
    }
    
    struct EditAmount {
        struct Request {
            let amount: Decimal
        }
        
        struct Response {
            let amountValid: Bool
        }
        
        struct ViewModel {
            let amountValid: Bool
        }
    }
    
    public struct AtomicSwapBuyAction {
        public struct Request {}
        public enum Response {
            case loading
            case loaded
            case failed(AtomicSwapError)
            case succeeded(Model.AtomicSwapPaymentType)
        }
        
        public enum ViewModel {
            case loading
            case loaded
            case failed(errorMessage: String)
            case succeeded(Model.AtomicSwapPaymentViewType)
        }
    }
}

extension AtomicSwapBuy.Event.AtomicSwapBuyAction {
    
    public enum AtomicSwapError: Error, LocalizedError {
        case emptyAmount
        case bidMoreThanAsk
        case failedToFecthAskId
        case askIsNotFound
        case failedToDecodeSourceAccountId
        case failedToBuildTransaction
        case failedToSendTransaction
        case failedToFetchCreateBidRequest
        case createBidRequestIsNotFound
        case externalDetailsAreNotFound
        case paymentIsRejected
        case paymentUrlIsInvalid
        case other(Error)
        
        // MARK: - LocalizedError
        
        public var errorDescription: String? {
            switch self {
                
            case .emptyAmount:
                return Localized(.empty_amount)
                
            case .bidMoreThanAsk:
                return Localized(.amount_is_too_big)
                
            case .askIsNotFound:
                return Localized(.ask_is_not_found)
                
            case .createBidRequestIsNotFound:
                return Localized(.create_bid_request_is_not_found)
                
            case .externalDetailsAreNotFound:
                return Localized(.external_details_are_not_found)
                
            case .failedToBuildTransaction:
                return Localized(.failed_to_build_transaction)
                
            case .failedToDecodeSourceAccountId:
                return Localized(.failed_to_decode_account_id)
                
            case .failedToFecthAskId:
                return Localized(.failed_to_fetch_ask_id)
                
            case .failedToFetchCreateBidRequest:
                return Localized(.failed_to_fetch_create_bid_request)
                
            case .failedToSendTransaction:
                return Localized(.failed_to_send_transaction)
                
            case .other(let error):
                return error.localizedDescription
                
            case .paymentIsRejected:
                return Localized(.payment_rejected)
                
            case .paymentUrlIsInvalid:
                return Localized(.payment_url_is_invalid)
            }
        }
    }
}
