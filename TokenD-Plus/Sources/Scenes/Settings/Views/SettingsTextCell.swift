import UIKit

enum SettingsTextCell {
    struct Model: CellViewModel {
        
        let title: String
        let topSeparator: Settings.Model.CellModel.SeparatorStyle
        let bottomSeparator: Settings.Model.CellModel.SeparatorStyle
        let identifier: Settings.CellIdentifier
        
        func setup(cell: SettingsTextCell.View) {
            cell.title = self.title
            cell.topSeparatorValue = self.topSeparator
            cell.bottomSeparatorValue = self.bottomSeparator
        }
    }
    
    class View: Settings.SettingsBaseCell {
        
        // MARK: - Private properties
        
        private let titleLabel: UILabel = UILabel()
        private let valueLabel: UILabel = UILabel()
        
        // MARK: - Public properties
        
        public var title: String? {
            get { return self.titleLabel.text }
            set { self.titleLabel.text = newValue }
        }
        
        // MARK: - Initializers
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            self.commonInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Private
        
        private func commonInit() {
            self.setupView()
            self.setupTitleLabel()
            
            self.setupLayout()
        }
        
        private func setupView() {
            self.backgroundColor = Theme.Colors.clear
            self.selectionStyle = .none
        }
        
        private func setupTitleLabel() {
            self.titleLabel.font = Theme.Fonts.smallTextFont
            self.titleLabel.textColor = Theme.Colors.sideTextOnContainerBackgroundColor
            self.titleLabel.textAlignment = .center
        }
        
        private func setupLayout() {
            self.contentView.addSubview(self.titleLabel)
            
            self.titleLabel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(10.0)
            }
        }
    }
}
