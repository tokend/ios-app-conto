import UIKit
import Nuke

extension AtomicSwap {
    
    public enum InfoCell {
        
        public struct ViewModel: CellViewModel {
            let baseAsset: String
            
            public func setup(cell: Cell) {
                cell.baseAsset = self.baseAsset
            }
        }
        
        public class Cell: UITableViewCell {
            
            // MARK: - Public properties
            
            var baseAsset: String? {
                didSet {
                    self.infoLabel.text = Localized(
                        .this_orders_allow_you_to_buy,
                        replace: [
                            .this_orders_allow_you_to_buy_replace_asset: self.baseAsset ?? ""
                        ]
                    )
                }
            }
            
            // MARK: - Private properties
            
            private let container: UIView = UIView()
            private let infoLabel: UILabel = UILabel()
            private let iconView: UIImageView = UIImageView()
            
            private let sideInset: CGFloat = 15.0
            private let topInset: CGFloat = 10.0
            private let iconSize: CGFloat = 36.0
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
                self.setupContainer()
                self.setupNameLabel()
                self.setupIconView()
                
                self.setupLayout()
            }
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
                self.selectionStyle = .none
            }
            
            private func setupContainer() {
                self.container.backgroundColor = Theme.Colors.contentBackgroundColor
                self.container.layer.cornerRadius = 10.0
                self.container.layer.borderWidth = 0.75
                self.container.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupNameLabel() {
                self.infoLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.infoLabel.font = Theme.Fonts.plainTextFont
                self.infoLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
                self.infoLabel.numberOfLines = 0
            }
            
            private func setupIconView() {
                self.iconView.backgroundColor = Theme.Colors.contentBackgroundColor
                self.iconView.image = Assets.info.image
                self.iconView.tintColor = Theme.Colors.separatorOnContentBackgroundColor
            }
            
            private func setupLayout() {
                self.addSubview(self.container)
                self.container.addSubview(self.iconView)
                self.container.addSubview(self.infoLabel)
                
                self.container.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.bottom.equalToSuperview().inset(self.sideInset)
                }
                
                self.iconView.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(self.sideInset)
                    make.centerY.equalTo(self.infoLabel)
                    make.width.height.equalTo(self.iconSize)
                }
                
                self.infoLabel.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.iconView.snp.trailing).offset(self.sideInset)
                    make.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.bottom.equalToSuperview().inset(self.topInset)
                }
            }
        }
    }
}
