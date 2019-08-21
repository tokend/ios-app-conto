import UIKit
import Nuke

extension AtomicSwap {
    
    public enum PriceCell {
        
        public struct ViewModel: CellViewModel {
            let amount: String
            
            public func setup(cell: Cell) {
                cell.amount = self.amount
            }
        }
        
        public class Cell: UICollectionViewCell {
            
            // MARK: - Public properties
            
            var amount: String? {
                get { return self.priceLabel.text }
                set { self.priceLabel.text = newValue }
            }
            
            // MARK: - Private properties
            
            private let container: UIView = UIView()
            private let priceLabel: UILabel = UILabel()
            
            private let sideInset: CGFloat = 15.0
            private let topInset: CGFloat = 10.0
            private let iconSize: CGFloat = 36.0
            
            // MARK: -
            
            public override init(frame: CGRect) {
                super.init(frame: frame)
                self.commonInit()
            }
            
            required init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
                self.commonInit()
            }
            
            // MARK: - Private
            
            private func commonInit() {
                self.setupView()
                self.setupContainer()
                self.setupPriceLabel()
                
                self.setupLayout()
            }
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
            }
            
            private func setupContainer() {
                self.container.backgroundColor = Theme.Colors.contentBackgroundColor
                self.container.layer.cornerRadius = 8.0
                self.container.layer.borderWidth = 0.75
                self.container.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupPriceLabel() {
                self.priceLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.priceLabel.font = Theme.Fonts.plainTextFont
            }
            
            private func setupLayout() {
                self.addSubview(self.container)
                self.container.addSubview(self.priceLabel)
                
                self.container.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.priceLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.bottom.equalToSuperview()
                }
            }
        }
    }
}
