import UIKit

public enum PaymentMethod {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension PaymentMethod.Model {
    public typealias AskModel = SendPaymentAmount.Model.AskModel
    
    public struct SceneModel {
        let baseAssetCode: String
        let baseAssetName: String
        let baseAmount: Decimal
        var methods: [PaymentMethod]
        var selectedPaymentMethod: PaymentMethod?
    }
    
    public struct PaymentMethod: Equatable {
        let assetCode: String
        let assetName: String
        let amount: Decimal
        
        public static func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
            return lhs.assetCode == rhs.assetCode
        }
    }
    
    public struct PaymentMethodViewModel {
        let asset: String
        let toPayAmount: String
    }
    
    public struct AtomicSwapInvoice {
        let address: String
        let asset: String
        let amount: Decimal
    }
    
    public struct AtomicSwapInvoiceViewModel {
        let address: String
        let amount: String
    }

    
    public struct AtomicSwapFiatPayment {
        let secret: String
        let id: String
        let asset: String
        let amount: Decimal
    }
    
    public enum PaymentError: Swift.Error {
        case failedToFecthAskId
        case askIsNotFound
        case failedToDecodeSourceAccountId
        case failedToBuildTransaction
        case failedToSendTransaction
        case failedToFetchCreateBidRequest
        case createBidRequestIsNotFound
        case externalDetailsAreNotFound
        case paymentIsRejected
        case other(Error)
    }
    
    public enum LoadingStatus {
        case loaded
        case loading
    }
}

// MARK: - Events

extension PaymentMethod.Event {
    public typealias Model = PaymentMethod.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let baseAssetName: String
            let baseAmount: Decimal
            let selectedMethod: Model.PaymentMethod?
        }
        public struct ViewModel {
            let buyAmount: String
            let selectedMethod: Model.PaymentMethodViewModel?
        }
    }
    
    public enum PaymentAction {
        public struct Request {}
        public enum Response {
            case invoce(Model.AtomicSwapInvoice)
            case error(Error)
        }
        public enum ViewModel {
            case invoce(Model.AtomicSwapInvoiceViewModel)
            case error(String)
        }
    }
    
    public enum SelectPaymentMethod {
        public struct Request {}
        public struct Response {
            let methods: [Model.PaymentMethod]
        }
        public typealias ViewModel = Response
    }
    
    public enum PaymentMethodSelected {
        public struct Request {
            let assetName: String
        }
        public struct Response {
            let method: Model.PaymentMethod
        }
        public struct ViewModel {
            let method: Model.PaymentMethodViewModel
        }
    }
    
    public enum LoadingStatusDidChange {
        public typealias Response = Model.LoadingStatus
        public typealias ViewModel = Model.LoadingStatus
    }
}
