import UIKit

extension ReceiveAddress {
    
    class HeaderCell: UIView {
        
        // MARK: - Private properties
        
        private let headerLabel: BXFInteractiveLabel = BXFInteractiveLabel()
        
        // MARK: - Public properties
        
        public var text: String? {
            get { return self.headerLabel.text }
            set { self.headerLabel.text = newValue }
        }
        
        // MARK: - Overridden methods
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.commonInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Public
        
        private func commonInit() {
            self.setupCell()
            self.setupHeaderLabel()
            self.setupLayout()
        }
        
        private func setupCell() {
            self.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupHeaderLabel() {
            self.headerLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.headerLabel.font = Theme.Fonts.largePlainTextFont
            self.headerLabel.textAlignment = .center
            self.headerLabel.numberOfLines = 0
        }
        
        private func setupLayout() {
            self.addSubview(self.headerLabel)
        
            self.headerLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(20.0)
                make.top.bottom.equalToSuperview()
            }
        }
    }
}
