import UIKit

public protocol AcceptRedeemDisplayLogic: class {
    typealias Event = AcceptRedeem.Event
    
    func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel)
    func displayAcceptRedeemRequestHandled(viewModel: Event.AcceptRedeemRequestHandled.ViewModel)
}

extension AcceptRedeem {
    public typealias DisplayLogic = AcceptRedeemDisplayLogic
    
    @objc(AcceptRedeemViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = AcceptRedeem.Event
        public typealias Model = AcceptRedeem.Model
        
        // MARK: -
        
        deinit {
            self.onDeinit?(self)
        }
        
        // MARK: - Injections
        
        private var interactorDispatch: InteractorDispatch?
        private var routing: Routing?
        private var onDeinit: DeinitCompletion = nil
        
        public func inject(
            interactorDispatch: InteractorDispatch?,
            routing: Routing?,
            onDeinit: DeinitCompletion = nil
            ) {
            
            self.interactorDispatch = interactorDispatch
            self.routing = routing
            self.onDeinit = onDeinit
        }
        
        // MARK: - Overridden
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            self.setupView()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
    }
}

extension AcceptRedeem.ViewController: AcceptRedeem.DisplayLogic {
    
    public func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel) {
        switch viewModel {
            
        case .loaded:
            self.routing?.hideProgress()
            
        case .loading:
            self.routing?.showProgress()
        }
    }
    
    public func displayAcceptRedeemRequestHandled(viewModel: Event.AcceptRedeemRequestHandled.ViewModel) {
        switch viewModel {
            
        case .failure(let message):
            self.routing?.showError(message)
            
        case .success(let redeemModel):
            self.routing?.onConfirmRedeem(redeemModel)
        }
    }
}
