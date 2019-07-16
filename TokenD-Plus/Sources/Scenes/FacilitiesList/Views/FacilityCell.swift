import RxCocoa
import RxSwift
import SnapKit
import UIKit

extension FacilitiesList {
    
    enum FacilityCell {
        struct ViewModel: CellViewModel {
            
            let title: String
            let icon: UIImage
            let type: Model.FacilityItem.FacilityType
            
            func setup(cell: View) {
                cell.title = self.title
                cell.icon = self.icon
            }
        }
        
        class View: UITableViewCell {
            
            // MARK: - Private properties
            
            private let disposeBag = DisposeBag()
            
            private let titleLabel: UILabel = UILabel()
            private let iconImageView: UIImageView = UIImageView()
            
            private let sideInset: CGFloat = 15.0
            private let topInset: CGFloat = 10.0
            private let iconSize: CGFloat = 24.0
            
            // MARK: - Public properties
            
            public var title: String? {
                get { return self.titleLabel.text }
                set { self.titleLabel.text = newValue }
            }
            public var icon: UIImage? {
                get { return self.iconImageView.image }
                set { self.iconImageView.image = newValue }
            }
            
            // MARK: - Initializers
            
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
                self.setupTitleLabel()
                self.setupIconImageView()
                
                self.setupLayout()
            }
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
                self.selectionStyle = .none
                self.accessoryType = .disclosureIndicator
                self.separatorInset.left = self.sideInset * 2 + self.iconSize
            }
            
            private func setupTitleLabel() {
                self.titleLabel.font = Theme.Fonts.plainTextFont
                self.titleLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.titleLabel.textAlignment = .left
                self.titleLabel.numberOfLines = 1
                self.titleLabel.lineBreakMode = .byWordWrapping
            }
            
            private func setupIconImageView() {
                self.iconImageView.tintColor = Theme.Colors.iconColor
                self.iconImageView.clipsToBounds = true
                self.iconImageView.layer.masksToBounds = true
            }
            
            private func setupLayout() {
                self.addSubview(self.iconImageView)
                self.addSubview(self.titleLabel)
                
                self.iconImageView.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(self.sideInset)
                    make.top.bottom.equalToSuperview().inset(self.topInset)
                    make.width.height.equalTo(self.iconSize)
                }
                
                self.titleLabel.snp.makeConstraints { (make) in
                    make.top.bottom.equalToSuperview().inset(self.topInset)
                    
                    make.leading.equalTo(self.iconImageView.snp.trailing).offset(self.sideInset)
                    make.trailing.equalToSuperview().offset(self.sideInset)
                }
            }
        }
    }
}
