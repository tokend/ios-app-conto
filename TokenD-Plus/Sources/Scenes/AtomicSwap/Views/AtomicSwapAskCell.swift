import UIKit
import RxSwift

extension AtomicSwap {
    
    enum AskCell {
        
        public struct ViewModel: CellViewModel {
            let id: String
            let availableAmount: String
            let pricesAmounts: [PriceCell.ViewModel]
            let baseAsset: String
            
            public func setup(cell: View) {
                cell.availableAmount = self.availableAmount
                cell.pricesAmounts = self.pricesAmounts
                cell.baseAsset = self.baseAsset
            }
        }
        
        public class View: UITableViewCell {
            
            // MARK: - Public properties
            
            var availableAmount: String? {
                get { return self.availableAmountLabel.text}
                set { self.availableAmountLabel.text = newValue }
            }
            
            var baseAsset: String? {
                get { return self.priceTextLabel.text }
                set { self.priceTextLabel.text = Localized(
                    .with_one_for,
                    replace: [
                        .with_one_for_replace_asset: newValue ?? ""
                    ])
                }
            }
            
            var pricesAmounts: [PriceCell.ViewModel] = [] {
                didSet {
                    self.pricesCollection.reloadData()
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
            private let pricesCollection: UICollectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: .init()
            )
            private let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            
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
                self.setupPriceCollectionLayout()
                self.setupPriceCollection()
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
                self.availableAmountLabel.font = Theme.Fonts.hugeTitleFont
                self.availableAmountLabel.textAlignment = .center
            }
            
            private func setupAvailableTextLabel() {
                self.availableTextLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.availableTextLabel.text = Localized(.available_lowercase)
                self.availableTextLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
                self.availableTextLabel.font = Theme.Fonts.smallTextFont
                self.availableTextLabel.textAlignment = .center
            }
            
            private func setupPriceContainer() {
                self.priceContainer.backgroundColor = Theme.Colors.contentBackgroundColor
            }
            
            private func setupPriceTextLabel() {
                self.priceTextLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.priceTextLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
                self.priceTextLabel.font = Theme.Fonts.smallTextFont
            }
            
            private func setupPriceCollectionLayout() {
                self.flowLayout.estimatedItemSize = CGSize(width: 50, height: 20)
                self.flowLayout.minimumInteritemSpacing = 3.0
            }
            
            private func setupPriceCollection() {
                self.pricesCollection.backgroundColor = Theme.Colors.contentBackgroundColor
                self.pricesCollection.register(classes: [
                        PriceCell.ViewModel.self
                    ]
                )
                self.pricesCollection.dataSource = self
                self.pricesCollection.delegate = self
                self.pricesCollection.isScrollEnabled = false
                self.pricesCollection.setCollectionViewLayout(
                    self.flowLayout,
                    animated: false
                )
            }
            
            private func setupActionButton() {
                self.actionButton.backgroundColor = Theme.Colors.contentBackgroundColor
                self.actionButton.setTitle(
                    Localized(.buy_action),
                    for: .normal
                )
                self.actionButton.setTitleColor(
                    Theme.Colors.accentColor,
                    for: .normal
                )
                self.actionButton.contentEdgeInsets.top = 20.0
                self.actionButton.titleLabel?.font = Theme.Fonts.actionButtonFont
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
                self.priceContainer.addSubview(self.pricesCollection)
                
                // MARK: - Layout cardView
                
                self.cardView.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.bottom.equalToSuperview()
                }
                
                self.availableContainer.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(self.sideInset)
                    make.top.equalToSuperview().inset(self.topInset)
                    make.bottom.lessThanOrEqualTo(self.actionButton.snp.top)
                }
                
                self.priceContainer.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.availableContainer.snp.trailing).offset(self.sideInset)
                    make.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.equalToSuperview().inset(self.topInset)
                    make.bottom.equalToSuperview()
                }
                
                self.actionButton.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(self.sideInset)
                    make.bottom.equalToSuperview().inset(self.sideInset)
                }
                
                // MARK: - Layout Available container
                
                self.availableAmountLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.top.equalToSuperview()
                }
                
                self.availableTextLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.bottom.equalToSuperview()
                    make.top.equalTo(self.availableAmountLabel.snp.bottom)
                    make.bottom.equalToSuperview()
                }
                
                // MARK: - Layout Price container
                
                self.priceTextLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.top.equalToSuperview()
                }
                
                self.pricesCollection.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalTo(self.priceTextLabel.snp.bottom).offset(self.topInset)
                    make.bottom.equalToSuperview().inset(self.topInset)
                }
            }
        }
    }
}

extension AtomicSwap.AskCell.View: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.pricesAmounts.isEmpty ? 0 : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pricesAmounts.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.pricesAmounts[indexPath.row]
        let cell = self.pricesCollection.dequeueReusableCell(with: model, for: indexPath)
        return cell
    }
    
}

extension AtomicSwap.AskCell.View: UICollectionViewDelegate  {
    
}
