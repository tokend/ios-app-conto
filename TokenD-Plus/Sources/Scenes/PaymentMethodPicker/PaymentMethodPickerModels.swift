import UIKit

public enum PaymentMethodPicker {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension PaymentMethodPicker.Model {
    public typealias PaymentMethodModel = PaymentMethod.Model.PaymentMethod
    
    public struct SceneModel {
        let methods: [PaymentMethodModel]
    }
}

// MARK: - Events

extension PaymentMethodPicker.Event {
    public typealias Model = PaymentMethodPicker.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let methods: [Model.PaymentMethodModel]
        }
        public struct ViewModel {
            let methods: [PaymentMethodPicker.MethodCell.ViewModel]
        }
    }
}
