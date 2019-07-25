import UIKit
import RxSwift

public class TitleView: UIView {
    
    public var textColor: UIColor? {
        didSet {
            self.titleLabel.textColor = self.textColor
            self.subtitleLabel.textColor = self.textColor
        }
    }
    
    // MARK: - Private properties
    
    private let labelsContainer: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    private let subtitleLabel: UILabel = UILabel()
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let sideInset: CGFloat = 10.0
    private let topInset: CGFloat = 5.0
    
    // MARK: -
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
        self.setupLabelsContainer()
        self.setupPollsLabel()
        self.setupAssetLabel()
        self.setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupView()
        self.setupLabelsContainer()
        self.setupPollsLabel()
        self.setupAssetLabel()
        self.setupLayout()
    }
    
    // MARK: - Public
    
    public func set(title: String, subtitle: String) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }
    
    // MARK: - Private
    
    private func setupView() {
        self.backgroundColor = Theme.Colors.contentBackgroundColor
    }
    
    private func setupLabelsContainer() {
        self.labelsContainer.backgroundColor = Theme.Colors.contentBackgroundColor
    }
    
    private func setupPollsLabel() {
        self.titleLabel.backgroundColor = Theme.Colors.contentBackgroundColor
        self.titleLabel.font = Theme.Fonts.plainBoldTextFont
        self.titleLabel.text = Localized(.polls)
        self.titleLabel.textAlignment = .center
    }
    
    private func setupAssetLabel() {
        self.subtitleLabel.backgroundColor = Theme.Colors.contentBackgroundColor
        self.subtitleLabel.textColor = Theme.Colors.separatorOnContentBackgroundColor
        self.subtitleLabel.font = Theme.Fonts.plainTextFont
        self.subtitleLabel.textAlignment = .center
    }
    
    private func setupLayout() {
        self.addSubview(self.labelsContainer)
        self.labelsContainer.addSubview(self.titleLabel)
        self.labelsContainer.addSubview(self.subtitleLabel)
        
        self.labelsContainer.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(self.topInset)
            make.height.equalTo(17.5)
        }
        
        self.subtitleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.topInset)
            make.bottom.equalToSuperview().inset(self.topInset)
        }
    }
}
