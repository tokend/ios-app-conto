import UIKit

extension SideMenu {
    class HeaderView: UIView {
        
        // MARK: - Private properties
        
        private let iconImageView: UIImageView = UIImageView()
        private let qrIconContainer: UIView = UIView()
        private let qrIcon: UIImageView = UIImageView()
        private let titleLabel: UILabel = UILabel()
        private let subTitleLabel: UILabel = UILabel()
        private let appNameLoginSeparator: UIView = UIView()
        
        // MARK: - Public properties
        
        let horizontalOffset: CGFloat = 15.0
        let verticalOffset: CGFloat = 6.0
        
        let qrIconSize: CGFloat = 27.5
        
        var iconImage: UIImage? {
            get { return self.iconImageView.image }
            set {
                self.iconImageView.image = newValue
                self.updateLayout()
            }
        }
        
        var title: String? {
            get { return self.titleLabel.text }
            set { self.titleLabel.text = newValue }
        }
        
        var subTitle: String? {
            get { return self.subTitleLabel.text }
            set { self.subTitleLabel.text = newValue }
        }
        
        // MARK: -
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.customInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            self.customInit()
        }
        
        private func customInit() {
            self.backgroundColor = UIColor.clear
            
            self.setupIconImageView()
            self.setupQrIconContainer()
            self.setupQrIcon()
            self.setupTitleLabel()
            self.setupSubTitleLabel()
            self.setupAppNameLoginSeparator()
            
            self.setupLayout()
        }
        
        // MARK: - Private
        
        private func setupIconImageView() {
            self.iconImageView.contentMode = .scaleAspectFit
            self.iconImageView.tintColor = Theme.Colors.darkAccentColor
        }
        
        private func setupQrIcon() {
            self.qrIcon.backgroundColor = Theme.Colors.contentBackgroundColor
            self.qrIcon.tintColor = Theme.Colors.separatorOnContentBackgroundColor
            self.qrIcon.layer.cornerRadius = self.qrIconSize / 2
            self.qrIcon.image = Assets.scanQrIcon.image
        }
        
        private func setupQrIconContainer() {
            self.qrIconContainer.backgroundColor = Theme.Colors.contentBackgroundColor
            self.qrIconContainer.layer.cornerRadius = self.qrIconSize / 2
            self.qrIconContainer.layer.shadowColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            self.qrIconContainer.layer.shadowOpacity = 1
            self.qrIconContainer.layer.shadowOffset = .zero
            self.qrIconContainer.layer.shadowRadius = 2
        }
        
        private func setupTitleLabel() {
            self.titleLabel.backgroundColor = UIColor.clear
            self.titleLabel.textColor = Theme.Colors.textOnMainColor
            self.titleLabel.font = Theme.Fonts.plainBoldTextFont
        }
        
        private func setupSubTitleLabel() {
            self.subTitleLabel.backgroundColor = UIColor.clear
            self.subTitleLabel.textColor = Theme.Colors.textOnMainColor
            self.subTitleLabel.font = Theme.Fonts.plainTextFont
        }
        
        private func setupAppNameLoginSeparator() {
            self.appNameLoginSeparator.backgroundColor = UIColor.clear
            self.appNameLoginSeparator.isUserInteractionEnabled = false
        }
        
        private func setupLayout() {
            self.addSubview(self.iconImageView)
            self.addSubview(self.qrIconContainer)
            self.addSubview(self.appNameLoginSeparator)
            self.addSubview(self.titleLabel)
            self.addSubview(self.subTitleLabel)
            
            self.qrIconContainer.addSubview(self.qrIcon)
            
            self.updateLayout()
            
            self.titleLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalTo(self.appNameLoginSeparator)
                make.bottom.equalTo(self.appNameLoginSeparator.snp.top)
            }
            
            self.subTitleLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalTo(self.titleLabel)
                make.top.equalTo(self.appNameLoginSeparator.snp.bottom)
            }
        }
        
        private func updateLayout() {
            if self.iconImage == nil {
                self.iconImageView.snp.remakeConstraints { (make) in
                    make.leading.top.equalToSuperview()
                    make.size.equalTo(0.0)
                }
                self.qrIconContainer.snp.remakeConstraints { (make) in
                    make.centerX.equalTo(self.iconImageView.snp.trailing)
                    make.bottom.equalTo(self.iconImageView)
                    make.size.equalTo(0.0)
                }
                self.qrIcon.snp.remakeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            } else {
                self.iconImageView.snp.remakeConstraints { (make) in
                    make.leading.top.bottom.equalToSuperview().inset(self.horizontalOffset)
                    make.width.equalTo(self.iconImageView.snp.height)
                }
                self.qrIconContainer.snp.remakeConstraints { (make) in
                    make.centerX.equalTo(self.iconImageView.snp.trailing).inset(10.0)
                    make.bottom.equalTo(self.iconImageView)
                    make.size.equalTo(self.qrIconSize)
                }
                
                self.qrIcon.snp.remakeConstraints { (make) in
                    make.edges.equalToSuperview().inset(5.0)
                }
            }
            
            self.appNameLoginSeparator.snp.remakeConstraints { (make) in
                if self.iconImage == nil {
                    make.leading.equalToSuperview().inset(self.horizontalOffset)
                } else {
                    make.leading.equalTo(self.iconImageView.snp.trailing).offset(self.horizontalOffset)
                }
                
                make.trailing.equalToSuperview().inset(self.horizontalOffset)
                make.centerY.equalToSuperview()
                make.height.equalTo(self.verticalOffset)
            }
        }
    }
}
