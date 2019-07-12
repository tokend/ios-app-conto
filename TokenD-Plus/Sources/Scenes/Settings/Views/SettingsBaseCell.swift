import UIKit

extension Settings {
    
    class SettingsBaseCell: UITableViewCell {
        
        // MARK: - Private properties
        
        private let topSeparator: UIView = UIView()
        private let bottomSeparator: UIView = UIView()
        
        public var topSeparatorValue: Settings.Model.CellModel.SeparatorStyle = .none {
            didSet {
                self.updateTopSeparator()
            }
        }
        
        public var bottomSeparatorValue: Settings.Model.CellModel.SeparatorStyle = .none {
            didSet {
                self.updateBottomSeparator()
            }
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            self.setupSeparators()
            self.setupLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.setupSeparators()
            self.setupLayout()
        }
        
        // MARK: - Private
        
        private func setupSeparators() {
            self.topSeparator.backgroundColor = Theme.Colors.separatorOnContentBackgroundColor
            self.bottomSeparator.backgroundColor = Theme.Colors.separatorOnContentBackgroundColor
        }
        
        private func updateTopSeparator() {
            switch self.topSeparatorValue {
                
            case .none:
                self.topSeparator.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(0.0)
                }
                
            case .line:
                self.topSeparator.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalToSuperview().inset(-1.0 / UIScreen.main.scale)
                    make.height.equalTo(1.0 / UIScreen.main.scale)
                }
                
            case .lineWithInset:
                self.topSeparator.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().inset(20.0)
                    make.trailing.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.equalTo(1.0 / UIScreen.main.scale)
                }
            }
        }
        
        private func updateBottomSeparator() {
            switch self.bottomSeparatorValue {
                
            case .none:
                self.bottomSeparator.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(0.0)
                }
                
            case .line:
                self.bottomSeparator.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalToSuperview().inset(-1.0 / UIScreen.main.scale)
                    make.height.equalTo(1.0 / UIScreen.main.scale)
                }
                
            case .lineWithInset:
                self.bottomSeparator.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().inset(20.0)
                    make.trailing.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.height.equalTo(1.0 / UIScreen.main.scale)
                }
            }
        }
        
        private func setupLayout() {
            self.addSubview(self.topSeparator)
            self.addSubview(self.bottomSeparator)
            
            self.topSeparator.bringSubviewToFront(self)
            self.bottomSeparator.bringSubviewToFront(self)
        }
    }
}
