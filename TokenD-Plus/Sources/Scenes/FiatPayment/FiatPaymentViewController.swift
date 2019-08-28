import UIKit
import RxSwift

public protocol FiatPaymentDisplayLogic: class {
    typealias Event = FiatPayment.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
}

extension FiatPayment {
    public typealias DisplayLogic = FiatPaymentDisplayLogic
    
    @objc(FiatPaymentViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = FiatPayment.Event
        public typealias Model = FiatPayment.Model
        
        // MARK: - Private properties
        
        private let webView: UIWebView = UIWebView()
        private let disposeBag: DisposeBag = DisposeBag()
        
        private var redirectDomen: String?
        
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
            
            self.routing?.showLoading()
            
            self.setupView()
            self.setupWebView()
            self.setupLayout()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        
        private func setupWebView() {
            self.webView.backgroundColor = Theme.Colors.contentBackgroundColor
            self.webView.delegate = self
            self.webView
                .rx
                .didFinishLoad
                .debounce(0.5, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] (_) in
                    self?.routing?.hideLoading()
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupLayout() {
            self.view.addSubview(self.webView)
            self.webView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension FiatPayment.ViewController: FiatPayment.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.redirectDomen = viewModel.redirectDomen
        self.webView.loadRequest(viewModel.request)
    }
}

extension FiatPayment.ViewController: UIWebViewDelegate {
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        guard let url = request.url,
            let domen = url.host else {
                return false
        }
        
        if let redirectDomen = self.redirectDomen {
            if domen == redirectDomen {
                self.routing?.showComplete()
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
}
