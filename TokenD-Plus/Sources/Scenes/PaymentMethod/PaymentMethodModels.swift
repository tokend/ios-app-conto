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
    }
    
    public struct PaymentMethod {
        let asset: String
        let amount: Decimal
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
            let methods: [PaymentMethod]
        }
        public struct ViewModel {
            
        }
    }
}
