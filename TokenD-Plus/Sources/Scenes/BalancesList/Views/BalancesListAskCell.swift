import UIKit
import RxSwift
import Nuke

extension BalancesList {
    
    public enum AskCell {
        
        public struct ViewModel: CellViewModel {
            let askId: String
            let assetName: String
            let imageRepresentation: BalancesList.Model.ImageRepresentation
            let price: String
            let available: String
            let abbreviationBackgroundColor: UIColor
            let abbreviationText: String
            let cellIdentifier: Model.CellIdentifier
            
            public func setup(cell: Cell) {
                cell.assetName = self.assetName
                cell.price = self.price
                cell.available = self.available
                cell.imageRepresentation = self.imageRepresentation
                cell.abbreviationBackgroundColor = self.abbreviationBackgroundColor
                cell.abbreviationText = self.abbreviationText
                cell.cellIdentifier = self.cellIdentifier
            }
        }
        
        public class Cell: UITableViewCell {
            
            // MARK: - Public properties
            
            var assetName: String? {
                get { return self.assetNameLabel.text }
                set { self.assetNameLabel.text = newValue }
            }
            
            var price: String? {
                get { return self.priceLabel.text }
                set { self.priceLabel.text = newValue }
            }
            
            var available: String? {
                get { return self.availableLabel.text }
                set { self.availableLabel.text = newValue }
            }
            
            var imageRepresentation: BalancesList.Model.ImageRepresentation? {
                didSet {
                    self.updateImage()
                }
            }
            
            var abbreviationBackgroundColor: UIColor? {
                get { return self.abbreviationView.backgroundColor }
                set { self.abbreviationView.backgroundColor = newValue }
            }
            
            var abbreviationText: String? {
                get { return self.abbreviationLabel.text }
                set { self.abbreviationLabel.text = newValue }
            }
            
            var cellIdentifier: Model.CellIdentifier?
            
            var onBuyAction: (() -> Void)?
            
            // MARK: - Private properties
            
            private let labelsContainer: UIView = UIView()
            
            private let assetNameLabel: UILabel = UILabel()
            private let priceLabel: UILabel = UILabel()
            private let availableLabel: UILabel = UILabel()
            
            private let buyButton: UIButton = UIButton()
            
            private let iconView: UIImageView = UIImageView()
            private let abbreviationView: UIView = UIView()
            private let abbreviationLabel: UILabel = UILabel()
            
            private let separator: UIView = UIView()
            
            private let sideInset: CGFloat = 20.0
            private let topInset: CGFloat = 15.0
            private let iconSize: CGFloat = 60.0
            
            private let disposeBag: DisposeBag = DisposeBag()
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                self.setupView()
                self.setupLabelsContainer()
                self.setupAssetNameLabel()
                self.setupPriceLabel()
                self.setupAvailableLabel()
                self.setupBuyButton()
                self.setupIconView()
                self.setupAbbreviationView()
                self.setupAbbreviationLabel()
                self.setupSeparator()
                self.setupLayout()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            // MARK: - Private
            
            private func updateImage() {
                guard let imageRepresentation = self.imageRepresentation else {
                    return
                }
                switch imageRepresentation {
                    
                case .abbreviation:
                    self.iconView.isHidden = true
                    
                case .image(let url):
                    self.iconView.isHidden = false
                    Nuke.loadImage(with: url, into: self.iconView)
                }
            }
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
                self.selectionStyle = .none
            }
            
            private func setupLabelsContainer() {
                self.labelsContainer.backgroundColor = Theme.Colors.contentBackgroundColor
            }
            
            private func setupAssetNameLabel() {
                self.assetNameLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.assetNameLabel.font = Theme.Fonts.largeTitleFont
            }
            
            private func setupPriceLabel() {
                self.priceLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.priceLabel.font = Theme.Fonts.plainTextFont
            }
            
            private func setupAvailableLabel() {
                self.availableLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.availableLabel.font = Theme.Fonts.plainTextFont
            }
            
            private func setupBuyButton() {
                self.buyButton.setTitle(
                    Localized(.buy_action),
                    for: .normal
                )
                self.buyButton.backgroundColor = Theme.Colors.contentBackgroundColor
                self.buyButton.setTitleColor(
                    Theme.Colors.accentColor,
                    for: .normal
                )
                self.buyButton.titleLabel?.font = Theme.Fonts.actionButtonFont
                
                self.buyButton
                    .rx
                    .tap
                    .asDriver()
                    .drive(onNext: { [weak self] (_) in
                        self?.onBuyAction?()
                    })
                .disposed(by: self.disposeBag)
            }
            
            private func setupIconView() {
                self.iconView.backgroundColor = Theme.Colors.contentBackgroundColor
                self.iconView.layer.cornerRadius = self.iconSize / 2
                self.iconView.contentMode = .scaleAspectFit
                self.iconView.clipsToBounds = true
                self.iconView.layer.borderWidth = 0.25
                self.iconView.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupAbbreviationView() {
                self.abbreviationView.layer.cornerRadius = self.iconSize / 2
                self.abbreviationView.layer.borderWidth = 0.25
                self.abbreviationView.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupAbbreviationLabel() {
                self.abbreviationLabel.textColor = Theme.Colors.textOnAccentColor
                self.abbreviationLabel.font = Theme.Fonts.hugeTitleFont
                self.abbreviationLabel.textAlignment = .center
            }
            
            private func setupSeparator() {
                self.separator.backgroundColor = Theme.Colors.separatorOnMainColor
            }
            
            private func setupLayout() {
                self.addSubview(self.abbreviationView)
                self.abbreviationView.addSubview(self.abbreviationLabel)
                self.addSubview(self.iconView)
                self.addSubview(self.labelsContainer)
                self.labelsContainer.addSubview(self.assetNameLabel)
                self.labelsContainer.addSubview(self.priceLabel)
                self.labelsContainer.addSubview(self.availableLabel)
                self.addSubview(self.buyButton)
                self.addSubview(self.separator)
                
                self.abbreviationView.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(self.sideInset)
                    make.top.equalToSuperview().inset(self.topInset)
                    make.height.width.equalTo(self.iconSize)
                }
                
                self.abbreviationLabel.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.iconView.snp.makeConstraints { (make) in
                    make.edges.equalTo(self.abbreviationView)
                }
                
                self.labelsContainer.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.abbreviationView.snp.trailing)
                    make.trailing.equalTo(self.buyButton.snp.leading).offset(-self.sideInset/2)
                    make.top.bottom.equalToSuperview()
                }
                
                self.assetNameLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.equalToSuperview().inset(self.topInset)
                }
                
                self.priceLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.equalTo(self.assetNameLabel.snp.bottom).offset(self.topInset)
                }
                
                self.availableLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.equalTo(self.priceLabel.snp.bottom).offset(self.topInset)
                    make.bottom.equalToSuperview().inset(self.topInset)
                }
                
                self.buyButton.snp.makeConstraints { (make) in
                    make.trailing.equalToSuperview().inset(self.sideInset)
                    make.bottom.equalToSuperview().inset(self.topInset / 2)
                    make.width.equalTo(60.0)
                    make.height.equalTo(30.0)
                }
                
                self.separator.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.labelsContainer)
                    make.trailing.bottom.equalToSuperview()
                    make.height.equalTo(1.0 / UIScreen.main.scale)
                }
            }
        }
    }
}
