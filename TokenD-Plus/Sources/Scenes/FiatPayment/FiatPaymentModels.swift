import UIKit

public enum FiatPayment {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension FiatPayment.Model {
    
    public struct SceneModel {
        let url: URL
    }
}

// MARK: - Events

extension FiatPayment.Event {
    public typealias Model = FiatPayment.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {
            let url: URL
        }
        public struct ViewModel {
            let request: URLRequest
        }
    }
}
