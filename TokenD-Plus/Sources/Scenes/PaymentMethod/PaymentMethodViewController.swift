import UIKit
import RxSwift

public protocol PaymentMethodDisplayLogic: class {
    typealias Event = PaymentMethod.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
    func displaySelectPaymentMethod(viewModel: Event.SelectPaymentMethod.ViewModel)
    func displayPaymentMethodSelected(viewModel: Event.PaymentMethodSelected.ViewModel)
    func displayPaymentAction(viewModel: Event.PaymentAction.ViewModel)
    func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel)
}

extension PaymentMethod {
    public typealias DisplayLogic = PaymentMethodDisplayLogic
    
    @objc(PaymentMethodViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = PaymentMethod.Event
        public typealias Model = PaymentMethod.Model
        
        // MARK: - Private properties
        
        private let buyLabel: UILabel = UILabel()
        private let paymentContainer: UIView = UIView()
        private let paymentHintContainer: UIView = UIView()
        private let paymentHintLabel: UILabel = UILabel()
        private let assetLabel: UILabel = UILabel()
        private let toPayLabel: UILabel = UILabel()
        private let dropButton: UIButton = UIButton()
        
        private let actionButton: UIButton = UIButton()
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        private let sideInset: CGFloat = 12.5
        private let topInset: CGFloat = 15.0
        
        private let buttonHeight: CGFloat = 55.0
        private let iconSize: CGFloat = 24.0
        
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
            self.setupBuyLabel()
            self.setupPaymentContainer()
            self.setupPaymentHintContainer()
            self.setupPaymentHintLabel()
            self.setupAssetLabel()
            self.setupToPayLabel()
            self.setupDropButton()
            self.setupActionButton()
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
        
        private func setupBuyLabel() {
            self.buyLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.buyLabel.font = Theme.Fonts.largeTitleFont
            self.buyLabel.textAlignment = .center
        }
        
        private func setupPaymentContainer() {
            self.paymentContainer.backgroundColor = Theme.Colors.contentBackgroundColor
            self.paymentContainer.layer.cornerRadius = 5.0
            self.paymentContainer.layer.borderWidth = 0.75
            self.paymentContainer.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
        }
        
        private func setupPaymentHintContainer() {
            self.paymentHintContainer.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupPaymentHintLabel() {
            self.paymentHintLabel.text = Localized(.payment_method)
            self.paymentHintLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.paymentHintLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
            self.paymentHintLabel.font = Theme.Fonts.smallTextFont
            self.paymentHintLabel.numberOfLines = 1
            self.paymentHintLabel.textAlignment = .center
        }
        
        private func setupAssetLabel() {
            self.assetLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.assetLabel.font = Theme.Fonts.largeTitleFont
        }
        
        private func setupToPayLabel() {
            self.toPayLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.toPayLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
            self.toPayLabel.font = Theme.Fonts.plainTextFont
        }
        
        private func setupDropButton() {
            self.dropButton.backgroundColor = Theme.Colors.contentBackgroundColor
            self.dropButton.tintColor = Theme.Colors.darkAccentColor
            self.dropButton.setImage(Assets.drop.image, for: .normal)
            self.dropButton
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    let request = Event.SelectPaymentMethod.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onSelectPaymentMethod(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupActionButton() {
            self.actionButton.backgroundColor = Theme.Colors.accentColor
            self.actionButton.setTitleColor(
                Theme.Colors.textOnAccentColor,
                for: .normal
            )
            self.actionButton.setTitle(
                Localized(.continue_capitalized),
                for: .normal
            )
            self.actionButton.titleLabel?.font = Theme.Fonts.actionButtonFont
            self.actionButton
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    let request = Event.PaymentAction.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onPaymentAction(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupLayout() {
            self.view.addSubview(self.buyLabel)
            self.view.addSubview(self.paymentContainer)
            self.view.addSubview(self.paymentHintContainer)
            self.view.addSubview(self.actionButton)
            
            self.paymentHintContainer.addSubview(self.paymentHintLabel)
            
            self.paymentContainer.addSubview(self.assetLabel)
            self.paymentContainer.addSubview(self.toPayLabel)
            self.paymentContainer.addSubview(self.dropButton)
            
            self.buyLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset)
                make.bottom.equalTo(self.paymentContainer.snp.top).offset(-50.0)
            }
            
            self.paymentHintContainer.snp.makeConstraints { (make) in
                make.leading.equalTo(self.paymentContainer).offset(self.sideInset)
                make.centerY.equalTo(self.paymentContainer.snp.top)
            }
            
            self.paymentContainer.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset * 2)
                make.centerY.equalToSuperview()
            }
            
            self.actionButton.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.safeArea.bottom)
                make.height.equalTo(self.buttonHeight)
            }
            
            self.paymentHintLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset / 2)
                make.top.bottom.equalToSuperview()
            }
            
            self.assetLabel.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().inset(self.sideInset)
                make.trailing.equalTo(self.dropButton.snp.leading).offset(-self.sideInset)
                make.top.equalToSuperview().inset(self.topInset)
            }
            
            self.toPayLabel.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().inset(self.sideInset)
                make.trailing.equalTo(self.dropButton.snp.leading).offset(-self.sideInset)
                make.top.equalTo(self.assetLabel.snp.bottom).offset(self.topInset / 2)
                make.bottom.equalToSuperview().inset(self.topInset)
            }
            
            self.dropButton.snp.makeConstraints { (make) in
                make.trailing.equalToSuperview().inset(self.sideInset)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(self.iconSize)
            }
        }
    }
}

extension PaymentMethod.ViewController: PaymentMethod.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.buyLabel.text = viewModel.buyAmount
        self.assetLabel.text = viewModel.selectedMethod?.asset
        self.toPayLabel.text = viewModel.selectedMethod?.toPayAmount
    }
    
    public func displaySelectPaymentMethod(viewModel: Event.SelectPaymentMethod.ViewModel) {
        
        let completion: (String) -> Void = { [weak self] (asset) in
            let request = Event.PaymentMethodSelected.Request(asset: asset)
            self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                businessLogic.onPaymentMethodSelected(request: request)
            })
        }
        self.routing?.onPickPaymentMethod(viewModel.methods, completion)
    }
    
    public func displayPaymentMethodSelected(viewModel: Event.PaymentMethodSelected.ViewModel) {
        self.assetLabel.text = viewModel.method.asset
        self.toPayLabel.text = viewModel.method.toPayAmount
    }
    
    public func displayPaymentAction(viewModel: Event.PaymentAction.ViewModel) {
        switch viewModel {
            
        case .error(let error):
            self.routing?.showError(error)
            
        case .invoce(let invoice):
            //self.routing?.showAtomicSwapInvoice(invoice)
            break
        }
    }
    
    public func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel) {
        switch viewModel {
            
        case .loaded:
            self.routing?.hideLoading()
            
        case .loading:
            self.routing?.showLoading()
        }
    }
}
