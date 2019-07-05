import UIKit
import RxSwift

extension SideMenu {
    class HeaderView: UIView {
        
        // MARK: - Private properties
        
        private let iconImageView: UIImageView = UIImageView()
        private let titleLabel: UILabel = UILabel()
        private let subTitleLabel: UILabel = UILabel()
        private let pickerButton: UIButton = UIButton()
        private let appNameLoginSeparator: UIView = UIView()
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        private var isExpanded = false {
            didSet {
                self.rotatePicker()
            }
        }
        
        // MARK: - Public properties
        
        let horizontalOffset: CGFloat = 15.0
        let verticalOffset: CGFloat = 6.0
        
        var onPickerClicked: (() -> Void)?
        
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
            self.setupTitleLabel()
            self.setupSubTitleLabel()
            self.setupPickerButton()
            self.setupAppNameLoginSeparator()
            
            self.setupLayout()
        }
        
        func setExpanded(isExpanded: Bool) {
            self.isExpanded = isExpanded
        }
        
        // MARK: - Private
        
        func rotatePicker() {
            let angle: CGFloat = self.isExpanded ? .pi : 0
            let rotateTransform = CGAffineTransform(rotationAngle: angle)
            UIView.animate(withDuration: 0.25, animations: {
                self.pickerButton.transform = rotateTransform
            })
        }
        
        // MARK: - Setup
        
        private func setupIconImageView() {
            self.iconImageView.contentMode = .scaleAspectFit
            self.iconImageView.tintColor = Theme.Colors.darkAccentColor
        }
        
        private func setupTitleLabel() {
            self.titleLabel.backgroundColor = UIColor.clear
            self.titleLabel.textColor = Theme.Colors.textOnMainColor
            self.titleLabel.font = Theme.Fonts.largeTitleFont
        }
        
        private func setupSubTitleLabel() {
            self.subTitleLabel.backgroundColor = UIColor.clear
            self.subTitleLabel.textColor = Theme.Colors.textOnMainColor
            self.subTitleLabel.font = Theme.Fonts.plainTextFont
        }
        
        private func setupPickerButton() {
            self.pickerButton.setImage(Assets.drop.image, for: .normal)
            self.pickerButton.tintColor = Theme.Colors.darkAccentColor
            self.pickerButton.contentEdgeInsets = UIEdgeInsets(
                top: 7.5,
                left: 7.5,
                bottom: 7.5,
                right: 7.5
            )
            self.pickerButton
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.isExpanded = !strongSelf.isExpanded
                    strongSelf.onPickerClicked?()
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupAppNameLoginSeparator() {
            self.appNameLoginSeparator.backgroundColor = UIColor.clear
            self.appNameLoginSeparator.isUserInteractionEnabled = false
        }
        
        private func setupLayout() {
            self.addSubview(self.iconImageView)
            self.addSubview(self.appNameLoginSeparator)
            self.addSubview(self.titleLabel)
            self.addSubview(self.subTitleLabel)
            self.addSubview(self.pickerButton)
            
            self.updateLayout()
            
            self.titleLabel.snp.makeConstraints { (make) in
                make.leading.equalTo(self.appNameLoginSeparator)
                make.bottom.equalTo(self.appNameLoginSeparator.snp.top)
            }
            
            self.pickerButton.snp.makeConstraints { (make) in
                make.leading.equalTo(self.titleLabel.snp.trailing).offset(5.0)
                make.trailing.lessThanOrEqualToSuperview()
                make.centerY.equalTo(self.titleLabel)
                make.width.height.equalTo(36.0)
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
            } else {
                self.iconImageView.snp.remakeConstraints { (make) in
                    make.leading.top.bottom.equalToSuperview().inset(self.horizontalOffset)
                    make.width.equalTo(self.iconImageView.snp.height)
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
