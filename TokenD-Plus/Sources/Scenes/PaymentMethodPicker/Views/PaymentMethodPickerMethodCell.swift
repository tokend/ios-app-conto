import UIKit
import Nuke

extension PaymentMethodPicker {
    
    public enum MethodCell {
        
        public struct ViewModel: CellViewModel {
            let asset: String
            let toPayAmount: String
            
            public func setup(cell: Cell) {
                cell.asset = self.asset
                cell.toPayAmount = self.toPayAmount
            }
        }
        
        public class Cell: UITableViewCell {
            
            // MARK: - Public properties
            
            var asset: String? {
                get { return self.assetLabel.text }
                set { self.assetLabel.text = newValue }
            }
            
            var toPayAmount: String? {
                get { return self.toPayAmountLabel.text }
                set { self.toPayAmountLabel.text = newValue }
            }
            
            // MARK: - Private properties
            
            private let assetLabel: UILabel = UILabel()
            private let toPayAmountLabel: UILabel = UILabel()
            
            private let sideInset: CGFloat = 20.0
            private let topInset: CGFloat = 15.0
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                self.setupView()
                self.setupAssetLabel()
                self.setupToPayAmountLabel()
                self.setupLayout()
            }
            
            required init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
                
                self.setupView()
                self.setupAssetLabel()
                self.setupToPayAmountLabel()
                self.setupLayout()
            }
            
            // MARK: - Private
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
                self.selectionStyle = .none
            }
            
            private func setupAssetLabel() {
                self.assetLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.assetLabel.font = Theme.Fonts.largeTitleFont
            }
            
            private func setupToPayAmountLabel() {
                self.toPayAmountLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.toPayAmountLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
                self.toPayAmountLabel.font = Theme.Fonts.plainTextFont
            }
            
            private func setupLayout() {
                self.addSubview(self.assetLabel)
                self.addSubview(self.toPayAmountLabel)
                
                self.assetLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.equalToSuperview().inset(self.topInset)
                }
                
                self.toPayAmountLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.equalTo(self.assetLabel.snp.bottom).offset(self.topInset / 2)
                    make.bottom.equalToSuperview().inset(self.topInset)
                }
            }
        }
    }
}
