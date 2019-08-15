import UIKit
import Nuke

extension BalancesList {
    
    public enum BalanceCell {
        
        public struct ViewModel: CellViewModel {
            let assetName: String
            let imageRepresentation: BalancesList.Model.ImageRepresentation
            let balance: String
            let abbreviationBackgroundColor: UIColor
            let abbreviationText: String
            let balanceId: String
            let cellIdentifier: Model.CellIdentifier
            
            public func setup(cell: Cell) {
                cell.assetName = self.assetName
                cell.imageRepresentation = self.imageRepresentation
                cell.balance = self.balance
                cell.abbreviationBackgroundColor = self.abbreviationBackgroundColor
                cell.abbreviationText = self.abbreviationText
                cell.cellIdentifier = self.cellIdentifier
            }
        }
        
        public class Cell: UITableViewCell {
            
            // MARK: - Public properties
            
            var code: String? {
                get { return self.codeLabel.text }
                set { self.codeLabel.text = newValue }
            }
            
            var assetName: String? {
                get { return self.nameLabel.text }
                set { self.nameLabel.text = newValue }
            }
            
            var imageRepresentation: BalancesList.Model.ImageRepresentation? {
                didSet {
                    self.updateImage()
                }
            }
            
            var balance: String? {
                get { return self.balanceLabel.text }
                set { self.balanceLabel.text = newValue }
            }
            
            var abbreviationBackgroundColor: UIColor? {
                get { return self.abbreviationView.backgroundColor }
                set { self.abbreviationView.backgroundColor = newValue }
            }
            
            var abbreviationText: String? {
                get { return self.abbreviationLabel.text }
                set { self.abbreviationLabel.text = newValue }
            }
            
            var cellIdentifier: Model.CellIdentifier?
            
            // MARK: - Private properties
            
            private let nameLabel: UILabel = UILabel()
            private let codeLabel: UILabel = UILabel()
            private let balanceLabel: UILabel = UILabel()
            
            private let iconView: UIImageView = UIImageView()
            private let abbreviationView: UIView = UIView()
            private let abbreviationLabel: UILabel = UILabel()
            
            private let separator: UIView = UIView()
            
            private let sideInset: CGFloat = 20.0
            private let topInset: CGFloat = 15.0
            private let iconSize: CGFloat = 60.0
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                self.setupView()
                self.setupNameLabel()
                self.setupBalanceLabel()
                self.setupIconView()
                self.setupAbbreviationView()
                self.setupAbbreviationLabel()
                self.setupSeparator()
                self.setupLayout()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            // MARK: - Private
            
            private func updateImage() {
                guard let imageRepresentation = self.imageRepresentation else {
                    return
                }
                switch imageRepresentation {
                    
                case .abbreviation:
                    self.iconView.isHidden = true
                    
                case .image(let url):
                    self.iconView.isHidden = false
                    Nuke.loadImage(with: url, into: self.iconView)
                }
            }
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
                self.selectionStyle = .none
            }
            
            private func setupNameLabel() {
                self.nameLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.nameLabel.font = Theme.Fonts.largeTitleFont
            }
            
            private func setupBalanceLabel() {
                self.balanceLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.balanceLabel.font = Theme.Fonts.plainTextFont
            }
            
            private func setupIconView() {
                self.iconView.backgroundColor = Theme.Colors.contentBackgroundColor
                self.iconView.layer.cornerRadius = self.iconSize / 2
                self.iconView.contentMode = .scaleAspectFit
                self.iconView.clipsToBounds = true
                self.iconView.layer.borderWidth = 0.25
                self.iconView.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupAbbreviationView() {
                self.abbreviationView.layer.cornerRadius = self.iconSize / 2
                self.abbreviationView.layer.borderWidth = 0.25
                self.abbreviationView.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupAbbreviationLabel() {
                self.abbreviationLabel.textColor = Theme.Colors.textOnAccentColor
                self.abbreviationLabel.font = Theme.Fonts.hugeTitleFont
                self.abbreviationLabel.textAlignment = .center
            }
            
            private func setupSeparator() {
                self.separator.backgroundColor = Theme.Colors.separatorOnMainColor
            }
            
            private func setupLayout() {
                self.addSubview(self.abbreviationView)
                self.abbreviationView.addSubview(self.abbreviationLabel)
                self.addSubview(self.iconView)
                self.addSubview(self.nameLabel)
                self.addSubview(self.balanceLabel)
                self.addSubview(self.separator)
                
                self.abbreviationView.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(self.sideInset)
                    make.top.bottom.equalToSuperview().inset(self.topInset)
                    make.height.width.equalTo(self.iconSize)
                }
                
                self.abbreviationLabel.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.iconView.snp.makeConstraints { (make) in
                    make.edges.equalTo(self.abbreviationView)
                }
                
                self.nameLabel.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.abbreviationView.snp.trailing).offset(self.sideInset)
                    make.trailing.equalToSuperview().inset(self.sideInset)
                    make.centerY.equalTo(self.abbreviationView.snp.centerY).offset(-self.topInset)
                }
                
                self.balanceLabel.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.abbreviationView.snp.trailing).offset(self.sideInset)
                    make.trailing.equalToSuperview().inset(self.sideInset)
                    make.centerY.equalTo(self.abbreviationView.snp.centerY).offset(self.topInset)
                }
                
                self.separator.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.nameLabel)
                    make.trailing.bottom.equalToSuperview()
                    make.height.equalTo(1.0 / UIScreen.main.scale)
                }
            }
        }
    }
}
