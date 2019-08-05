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
    
    public struct SceneModel {
        let baseAsset: String
        let baseAmount: Decimal
        var methods: [PaymentMethod]
        var selectedPaymentMethod: PaymentMethod?
    }
    
    public struct PaymentMethod: Equatable {
        let asset: String
        let amount: Decimal
        
        public static func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
            return lhs.asset == rhs.asset
        }
    }
    
    public struct PaymentMethodViewModel {
        let asset: String
        let toPayAmount: String
    }
}

// MARK: - Events

extension PaymentMethod.Event {
    public typealias Model = PaymentMethod.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let baseAsset: String
            let baseAmount: Decimal
            let selectedMethod: Model.PaymentMethod?
        }
        public struct ViewModel {
            let buyAmount: String
            let selectedMethod: Model.PaymentMethodViewModel?
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
            let asset: String
        }
        public struct Response {
            let method: Model.PaymentMethod
        }
        public struct ViewModel {
            let method: Model.PaymentMethodViewModel
        }
    }
}
