import UIKit

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
        
        private let amountContainer: UIView = UIView()
        private let amountHintLabel: UILabel = UILabel()
        private let amountLabel: UILabel = UILabel()
        private let amountSeparator: UIView = UIView()
        
        private let cardContainer: UIView = UIView()
        private let cardHintLabel: UILabel = UILabel()
        private let cardSeparator: UIView = UIView()
        
        private let topInset: CGFloat = 10.0
        private let sideInset: CGFloat = 15.0
        
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
            self.setupAmountHint()
            self.setupAmountLabel()
            self.setupAmountSeparatorLabel()
            self.setupCardHint()
            self.setupCardField()
            self.setupCardSeparatorLabel()
            
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
        
        private func setupAmountHint() {
            self.amountHintLabel.text = Localized(.amount)
            self.amountHintLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.amountHintLabel.font = Theme.Fonts.smallTextFont
            self.amountHintLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
        }
        
        private func setupAmountLabel() {
            self.amountLabel.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupAmountSeparatorLabel() {
            self.amountSeparator.backgroundColor = Theme.Colors.separatorOnContentBackgroundColor
        }
        
        private func setupCardHint() {
            self.cardHintLabel.text = Localized(.credit_card)
            self.cardHintLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.cardHintLabel.font = Theme.Fonts.smallTextFont
            self.cardHintLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
        }
        
        private func setupCardSeparatorLabel() {
            self.cardSeparator.backgroundColor = Theme.Colors.separatorOnContentBackgroundColor
        }
        
        private func setupLayout() {
            self.view.addSubview(self.amountContainer)
            self.view.addSubview(self.cardContainer)
            
            self.amountContainer.addSubview(self.amountHintLabel)
            self.amountContainer.addSubview(self.amountLabel)
            self.amountContainer.addSubview(self.amountSeparator)
            
            self.cardContainer.addSubview(self.cardHintLabel)
            self.cardContainer.addSubview(self.cardSeparator)
            
            
            self.amountContainer.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset)
                make.top.equalToSuperview().inset(self.topInset)
            }
            
            self.cardContainer.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset)
                make.top.equalTo(self.amountContainer.snp.bottom).offset(self.topInset)
            }
            
            self.amountHintLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            self.amountLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(self.amountHintLabel.snp.bottom).offset(self.topInset)
            }
            
            self.amountSeparator.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(self.amountLabel.snp.bottom)
                make.bottom.equalToSuperview()
                make.height.equalTo(1.0 / UIScreen.main.scale)
            }
            
            self.cardHintLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            self.cardSeparator.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(self.amountLabel.snp.bottom)
                make.bottom.equalToSuperview()
                make.height.equalTo(1.0 / UIScreen.main.scale)
            }
        }
    }
}

extension FiatPayment.ViewController: FiatPayment.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.amountLabel.text = viewModel.amount
    }
}
