import UIKit
import RxSwift

protocol AtomicSwapBuyDisplayLogic: class {
    
    typealias Event = AtomicSwapBuy.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
    func displaySelectQuoteAsset(viewModel: Event.SelectQuoteAsset.ViewModel)
    func displayQuoteAssetSelected(viewModel: Event.QuoteAssetSelected.ViewModel)
    func displayEditAmount(viewModel: Event.EditAmount.ViewModel)
    func displayAtomicSwapBuyAction(viewModel: Event.AtomicSwapBuyAction.ViewModel)
}

extension AtomicSwapBuy {
    typealias DisplayLogic = AtomicSwapBuyDisplayLogic
    
    class ViewController: UIViewController {
        
        typealias Model = AtomicSwapBuy.Model
        typealias Event = AtomicSwapBuy.Event
        
        // MARK: - Private properties
        
        private let containerView: UIView = UIView()
        private let inputAmountContainer: UIView = UIView()
        
        private let paymentMethodLabel: UILabel = UILabel()
        private let quoteAssetButton: UIButton = UIButton()
        private let separator: UIView = UIView()
        private let availableView: BalanceView = BalanceView()
        private let enterAmountView: EnterAmountView = EnterAmountView()
        
        private let actionButton: UIButton = UIButton()
        
        private let disposeBag = DisposeBag()
        
        private let buttonHeight: CGFloat = 45.0
        private let sideInset: CGFloat = 20.0
        private let topInset: CGFloat = 15.0
        private var viewDidAppear: Bool = false
        
        // MARK: - Injections
        
        private var interactorDispatch: InteractorDispatch?
        private var routing: Routing?
        
        func inject(
            interactorDispatch: InteractorDispatch?,
            routing: Routing?
            ) {
            
            self.interactorDispatch = interactorDispatch
            self.routing = routing
        }
        
        
        // MARK: - Overridden
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.setupView()
            self.setupContainerView()
            self.setupInputAmountContainer()
            self.setupPaymentMethodLabel()
            self.setupQuoteAssetButton()
            self.setupSeparator()
            self.setupBalanceView()
            self.setupEnterAmountView()
            self.setupActionButton()
            self.setupLayout()
            
            self.observeKeyboard()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            self.viewDidAppear = true
            
        }
        
        // MARK: - Private
        
        // MARK: - Observe
        
        private func observeKeyboard() {
            let keyboardObserver = KeyboardObserver(
                self,
                keyboardWillChange: { [weak self] (attributes) in
                    guard let strongSelf = self else {
                        return
                    }
                    let keyboardHeight = attributes.heightIn(view: strongSelf.view)
                    if attributes.showingIn(view: strongSelf.view) {
                        strongSelf.actionButton.snp.remakeConstraints { (make) in
                            make.leading.trailing.equalToSuperview()
                            make.bottom.equalToSuperview().inset(keyboardHeight)
                            make.height.equalTo(strongSelf.buttonHeight)
                        }
                    } else {
                        strongSelf.actionButton.snp.remakeConstraints { (make) in
                            make.leading.trailing.equalToSuperview()
                            make.bottom.equalTo(strongSelf.view.safeArea.bottom)
                            make.height.equalTo(strongSelf.buttonHeight)
                        }
                    }
                    
                    if strongSelf.viewDidAppear {
                        UIView.animate(withKeyboardAttributes: attributes, animations: {
                            strongSelf.view.layoutIfNeeded()
                        })
                    }
            })
            KeyboardController.shared.add(observer: keyboardObserver)
        }
        
        // MARK: - Update
        
        private func updateAmountValid(_ amountValid: Bool) {
            self.availableView.set(balanceHighlighted: !amountValid)
            self.enterAmountView.set(amountHighlighted: !amountValid)
        }
        
        // MARK: - Setup
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupContainerView() {
            self.containerView.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupInputAmountContainer() {
            self.inputAmountContainer.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupPaymentMethodLabel() {
            self.paymentMethodLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.paymentMethodLabel.text = Localized(.payment_method)
            self.paymentMethodLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
            self.paymentMethodLabel.font = Theme.Fonts.smallTextFont
            self.paymentMethodLabel.textAlignment = .center
        }
        
        private func setupQuoteAssetButton() {
            self.quoteAssetButton.tintColor = Theme.Colors.darkAccentColor
            self.quoteAssetButton.setTitleColor(
                Theme.Colors.darkAccentColor,
                for: .normal
            )
            self.quoteAssetButton
                .rx
                .controlEvent(.touchUpInside)
                .asDriver()
                .drive(onNext: { [weak self] in
                    let request = Event.SelectQuoteAsset.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onSelectQuoteAsset(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
            self.quoteAssetButton.setImage(
                Assets.drop.image,
                for: .normal
            )
            self.quoteAssetButton.semanticContentAttribute = .forceRightToLeft
            self.quoteAssetButton.contentEdgeInsets.right = 30.0
            self.quoteAssetButton.imageEdgeInsets.right = -30.0
        }
        
        private func setupSeparator() {
            self.separator.backgroundColor = Theme.Colors.separatorOnContentBackgroundColor
        }
        
        private func setupBalanceView() {
            self.availableView.title = Localized(.available_colon)
        }
        
        private func setupEnterAmountView() {
            self.enterAmountView.onEnterAmount = { [weak self] (amount) in
                let request = Event.EditAmount.Request(amount: amount ?? 0.0)
                self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                    businessLogic.onEditAmount(request: request)
                })
            }
            
            self.enterAmountView.onSelectAsset = { [weak self] in
                let request = Event.SelectQuoteAsset.Request()
                self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                    businessLogic.onSelectQuoteAsset(request: request)
                })
            }
            self.enterAmountView.hidePicker()
        }
        
        private func setupActionButton() {
            self.actionButton.setTitle(Localized(.confirm), for: .normal)
            self.actionButton.titleLabel?.font = Theme.Fonts.actionButtonFont
            self.actionButton.backgroundColor = Theme.Colors.accentColor
            self.actionButton
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.view.endEditing(true)
                    let request = Event.AtomicSwapBuyAction.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onAtomicSwapBuyAction(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupLayout() {
            self.view.addSubview(self.containerView)
            self.containerView.addSubview(self.inputAmountContainer)
            
            self.inputAmountContainer.addSubview(self.paymentMethodLabel)
            self.inputAmountContainer.addSubview(self.quoteAssetButton)
            self.inputAmountContainer.addSubview(self.separator)
            self.inputAmountContainer.addSubview(self.availableView)
            self.inputAmountContainer.addSubview(self.enterAmountView)
            self.view.addSubview(self.actionButton)
            
            self.containerView.snp.makeConstraints { (make) in
                make.leading.trailing.top.equalToSuperview()
                make.bottom.equalTo(self.actionButton.snp.top)
            }
            
            self.inputAmountContainer.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.trailing.equalToSuperview()
            }
            
            self.paymentMethodLabel.snp.makeConstraints { (make) in
                make.leading.trailing.top.equalToSuperview()
            }
            
            self.quoteAssetButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(self.paymentMethodLabel.snp.bottom).offset(self.topInset)
                make.height.equalTo(35.0)
            }
            
            self.separator.snp.makeConstraints { (make) in
                make.top.equalTo(self.quoteAssetButton.snp.bottom).offset(self.topInset)
                make.leading.trailing.equalToSuperview().inset(self.sideInset)
                make.height.equalTo(1.0 / UIScreen.main.scale)
            }
            
            self.availableView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset)
                make.top.equalTo(self.separator.snp.bottom).offset(self.topInset)
            }
            
            self.enterAmountView.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(self.availableView.snp.bottom).offset(15.0)
            }
            
            self.actionButton.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.safeArea.bottom)
                make.height.equalTo(self.buttonHeight)
            }
        }
    }
}

// MARK: - DisplayLogic

extension AtomicSwapBuy.ViewController: AtomicSwapBuy.DisplayLogic {
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.availableView.set(
            amount: viewModel.availableAmount,
            asset: viewModel.availableAsset
        )
        self.quoteAssetButton.setTitle(viewModel.selectedQuoteAsset, for: .normal)
    }
    
    func displaySelectQuoteAsset(viewModel: Event.SelectQuoteAsset.ViewModel) {
        let onSelected: (String) -> Void = { (quoteAsset) in
            self.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                let request = Event.QuoteAssetSelected.Request(asset: quoteAsset)
                businessLogic.onQuoteAssetSelected(request: request)
            })
        }
        self.routing?.onPresentPicker(viewModel.quoteAssets, onSelected)
    }
    
    func displayQuoteAssetSelected(viewModel: Event.QuoteAssetSelected.ViewModel) {
        self.quoteAssetButton.setTitle(viewModel.asset, for: .normal)
    }
    
    func displayEditAmount(viewModel: Event.EditAmount.ViewModel) {
        self.updateAmountValid(viewModel.amountValid)
    }
    
    func displayAtomicSwapBuyAction(viewModel: Event.AtomicSwapBuyAction.ViewModel) {
        switch viewModel {
            
        case .loaded:
            self.routing?.onHideProgress()
            
        case .loading:
            self.routing?.onShowProgress()
            
        case .failed(let errorMessage):
            self.routing?.onHideProgress()
            self.routing?.onShowError(errorMessage)
            
        case .succeeded(let paymentType):
            self.routing?.onHideProgress()
            
            switch paymentType {
                
            case .crypto(let crypto):
                self.routing?.onAtomicSwapCryptoBuyAction(crypto)
            case .fiat(let url):
                self.routing?.onAtomicSwapFiatBuyAction(url)
            }
        }
    }
}
