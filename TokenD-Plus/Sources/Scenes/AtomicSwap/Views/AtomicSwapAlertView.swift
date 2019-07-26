import UIKit
import RxSwift

extension AtomicSwap {
    
    enum AskCell {
        
        public struct ViewModel: CellViewModel {
            let availableAmount: String
            let priceAmount: String
            let baseAsset: String
            
            public func setup(cell: View) {
                cell.availableAmount = self.availableAmount
                cell.priceAmount = self.priceAmount
                cell.baseAsset = self.baseAsset
            }
        }
        
        public class View: UITableViewCell {
            
            // MARK: - Public properties
            
            var availableAmount: String? {
                get { return self.availableAmountLabel.text}
                set { self.availableAmountLabel.text = self.availableAmount }
            }
            
            var priceAmount: String? {
                get { return self.priceAmountLabel.text }
                set { self.priceAmountLabel.text = self.priceAmount }
            }
            
            var baseAsset: String? {
                get { return self.priceTextLabel.text }
                set { self.priceTextLabel.text = Localized(
                    .with_one_for,
                    replace: [
                        .with_one_for_replace_asset: self.baseAsset ?? ""
                    ])
                }
            }
            
            var onAction: (() -> Void)?
            
            // MARK: - Private properties
            
            private let cardView: UIView = UIView()
            
            private let availableContainer: UIView = UIView()
            private let availableAmountLabel: UILabel = UILabel()
            private let availableTextLabel: UILabel = UILabel()
            
            private let priceContainer: UIView = UIView()
            private let priceTextLabel: UILabel = UILabel()
            private let priceAmountContainer: UIView = UIView()
            private let priceAmountLabel: UILabel = UILabel()
            
            private let actionButton: UIButton = UIButton()
            
            private let disposeBag: DisposeBag = DisposeBag()
            
            private let sideInset: CGFloat = 15.0
            private let topInset: CGFloat = 10.0
            
            // MARK: -
            
            public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                self.commonInit()
            }
            
            required init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
                self.commonInit()
            }
            
            // MARK: - Private
            
            private func commonInit() {
                self.setupView()
                self.setupCardView()
                self.setupAvailableContainer()
                self.setupAvailableAmountLabel()
                self.setupAvailableTextLabel()
                self.setupPriceContainer()
                self.setupPriceTextLabel()
                self.setupPriceAmountContainer()
                self.setupPriceAmountLabel()
                self.setupActionButton()
                self.setupLayout()
            }
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
                self.selectionStyle = .none
            }
            
            private func setupCardView() {
                self.cardView.backgroundColor = Theme.Colors.contentBackgroundColor
                self.cardView.layer.borderWidth = 0.75
                self.cardView.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
                self.cardView.layer.cornerRadius = 10.0
            }
            
            private func setupAvailableContainer() {
                self.availableContainer.backgroundColor = Theme.Colors.contentBackgroundColor
            }
            
            private func setupAvailableAmountLabel() {
                self.availableAmountLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.availableAmountLabel.font = Theme.Fonts.largeTitleFont
                self.availableAmountLabel.textAlignment = .center
            }
            
            private func setupAvailableTextLabel() {
                self.availableTextLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.availableTextLabel.text = Localized(.available)
                self.availableTextLabel.textColor = Theme.Colors.neutralColor
                self.availableTextLabel.font = Theme.Fonts.smallTextFont
                self.availableTextLabel.textAlignment = .center
            }
            
            private func setupPriceContainer() {
                self.priceContainer.backgroundColor = Theme.Colors.contentBackgroundColor
            }
            
            private func setupPriceTextLabel() {
                self.priceTextLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.priceTextLabel.textColor = Theme.Colors.neutralColor
                self.priceTextLabel.font = Theme.Fonts.smallTextFont
            }
            
            private func setupPriceAmountContainer() {
                self.priceAmountContainer.backgroundColor = Theme.Colors.contentBackgroundColor
                self.priceAmountContainer.layer.borderWidth = 0.75
                self.priceAmountContainer.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
                self.priceAmountContainer.layer.cornerRadius = 2.0
            }
            
            private func setupPriceAmountLabel() {
                self.priceAmountLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.priceAmountLabel.font = Theme.Fonts.plainTextFont
            }
            
            private func setupActionButton() {
                self.actionButton.backgroundColor = Theme.Colors.contentBackgroundColor
                self.actionButton.setTitle(Localized(.buy), for: .normal)
                self.actionButton.setTitleColor(
                    Theme.Colors.accentColor,
                    for: .normal
                )
                self.actionButton
                    .rx
                    .tap
                    .asDriver()
                    .drive(onNext: { [weak self] (_) in
                        self?.onAction?()
                    })
                    .disposed(by: self.disposeBag)
            }
            
            private func setupLayout() {
                self.addSubview(self.cardView)
                
                self.cardView.addSubview(self.availableContainer)
                self.cardView.addSubview(self.priceContainer)
                self.cardView.addSubview(self.actionButton)
                
                self.availableContainer.addSubview(self.availableAmountLabel)
                self.availableContainer.addSubview(self.availableTextLabel)
                
                self.priceContainer.addSubview(self.priceTextLabel)
                self.priceContainer.addSubview(self.priceAmountContainer)
                
                self.priceAmountContainer.addSubview(self.priceAmountLabel)
                
                // MARK: - Layout cardView
                
                self.cardView.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                }
                
                self.availableContainer.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(self.sideInset)
                    make.top.equalToSuperview().inset(self.topInset)
                    make.bottom.equalTo(self.priceContainer)
                }
                
                self.priceContainer.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.availableContainer.snp.trailing).offset(self.sideInset)
                    make.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.equalToSuperview().inset(self.topInset)
                }
                
                self.actionButton.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(self.sideInset)
                    make.bottom.equalToSuperview().inset(self.topInset)
                }
                
                // MARK: - Layout Available container
                
                self.availableAmountLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.top.equalToSuperview()
                }
                
                self.availableTextLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.bottom.equalToSuperview()
                    make.top.equalTo(self.availableAmountLabel.snp.bottom)
                }
                
                self.availableContainer.setContentHuggingPriority(
                    .defaultHigh,
                    for: .horizontal
                )
                self.availableContainer.setContentCompressionResistancePriority(
                    .defaultLow,
                    for: .horizontal
                )
                
                // MARK: - Layout Price container
                
                self.priceTextLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.top.equalToSuperview()
                }
                
                self.priceAmountContainer.snp.makeConstraints { (make) in
                    make.leading.trailing.bottom.equalToSuperview()
                    make.top.equalTo(self.priceTextLabel.snp.bottom)
                }
                
                self.priceContainer.setContentHuggingPriority(
                    .defaultLow,
                    for: .horizontal
                )
                self.priceContainer.setContentCompressionResistancePriority(
                    .defaultHigh,
                    for: .horizontal
                )
                
                // MARK: - Layout Price amount container
                
                self.priceAmountLabel.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
}
