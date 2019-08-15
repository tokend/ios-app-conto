import UIKit
import RxSwift

public protocol KYCDisplayLogic: class {
    typealias Event = KYC.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
    func displayAction(viewModel: Event.Action.ViewModel)
    func displayKYCApproved(viewModel: Event.KYCApproved.ViewModel)
}

extension KYC {
    public typealias DisplayLogic = KYCDisplayLogic
    
    @objc(KYCViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = KYC.Event
        public typealias Model = KYC.Model
        
        // MARK: -
        
        deinit {
            self.onDeinit?(self)
        }
        
        // MARK: - Private properties
        
        private let contentView: View = View()
        
        private let disposeBag: DisposeBag = DisposeBag()
        
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
            self.setupSubmitButton()
            self.setupContentView()
            self.setupLayout()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func setupViewWithFields(_ fields: [View.Field]) {
            self.contentView.setupFields(fields)
        }
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupSubmitButton() {
            let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Checkmark"), style: .plain, target: nil, action: nil)
            button.rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.view.endEditing(true)
                    let request = Event.Action.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onAction(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
            self.navigationItem.rightBarButtonItem = button
        }
        
        private func setupContentView() {
            self.contentView.onEditField = { [weak self] fieldType, text in
                let request = Event.TextFieldValueDidChange.Request(fieldType: fieldType, text: text)
                self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                    businessLogic.onTextFieldValueDidChange(request: request)
                })
            }
        }
        
        private func setupLayout() {
            self.view.addSubview(self.contentView)
            self.contentView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension KYC.ViewController: KYC.DisplayLogic {
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.setupViewWithFields(viewModel.fields)
    }
    
    public func displayAction(viewModel: Event.Action.ViewModel) {
        switch viewModel {
            
        case .failure(let message):
            self.routing?.showError(message)
            
        case .loaded:
            self.routing?.hideLoading()
            
        case .loading:
            self.routing?.showLoading()
            
        case .success(let message):
            self.routing?.showMessage(message)
            
        case .validationError(let message):
            self.routing?.hideLoading()
            self.routing?.showValidationError(message)
        }
    }
    
    public func displayKYCApproved(viewModel: Event.KYCApproved.ViewModel) {
        self.routing?.showOnApproved()
    }
}
