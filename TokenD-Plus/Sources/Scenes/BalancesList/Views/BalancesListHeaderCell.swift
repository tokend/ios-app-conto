import UIKit
import Nuke

extension BalancesList {
    
    public enum HeaderCell {
        
        public struct ViewModel: CellViewModel {
            let imageUrl: URL?
            let abbreviationСolor: UIColor
            let abbreviationText: String
            let balance: String
            let cellIdentifier: Model.CellIdentifier
            
            public func setup(cell: Cell) {
                cell.imageUrl = self.imageUrl
                cell.abbreviationText = self.abbreviationText
                cell.abbreviationColor = self.abbreviationСolor
                cell.balance = self.balance
            }
        }
        
        public class Cell: UITableViewCell {
            
            // MARK: - Public properties
            
            var abbreviationColor: UIColor? {
                get { return self.abbreviationLabel.textColor }
                set { self.abbreviationLabel.textColor = newValue }
            }
            
            var abbreviationText: String? {
                get { return self.abbreviationLabel.text }
                set { self.abbreviationLabel.text = newValue }
            }
            
            var balance: String? {
                get { return self.balanceLabel.text }
                set { self.balanceLabel.text = newValue }
            }
            
            var imageUrl: URL? {
                didSet {
                    guard let url = self.imageUrl else {
                        self.companyImage.isHidden = true
                        return
                    }
                    self.companyImage.isHidden = false
                    Nuke.loadImage(
                        with: url,
                        into: self.companyImage
                    )
                }
            }
            
            var cellIdentifier: Model.CellIdentifier?
            
            // MARK: - Private properties
            
            private let abbreviationContainer: UIView = UIView()
            private let abbreviationLabel: UILabel = UILabel()
            private let companyImage: UIImageView = UIImageView()
            private let balanceLabel: UILabel = UILabel()
            
            private let imageSize: CGFloat = 70.0
            private let sideInset: CGFloat = 15.0
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                self.setupView()
                self.setupImageView()
                self.setupAbbreviationContainer()
                self.setupAbbreviationLabel()
                self.setupBalanceLabel()
                self.setupLayout()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            // MARK: - Private
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
                self.selectionStyle = .none
            }
            
            private func setupAbbreviationContainer() {
                self.abbreviationContainer.backgroundColor = Theme.Colors.contentBackgroundColor
                self.abbreviationContainer.layer.cornerRadius = self.imageSize / 2
                self.abbreviationContainer.layer.borderWidth = 0.25
                self.abbreviationContainer.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupAbbreviationLabel() {
                self.abbreviationLabel.textColor = Theme.Colors.textOnMainColor
                self.abbreviationLabel.font = Theme.Fonts.hugeTitleFont
                self.abbreviationLabel.textAlignment = .center
            }
            
            private func setupImageView() {
                self.companyImage.backgroundColor = Theme.Colors.contentBackgroundColor
                self.companyImage.layer.cornerRadius = self.imageSize / 2
                self.companyImage.clipsToBounds = true
                self.companyImage.layer.borderWidth = 0.25
                self.companyImage.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupBalanceLabel() {
                self.balanceLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.balanceLabel.font = Theme.Fonts.largeAssetFont
                self.balanceLabel.numberOfLines = 0
                self.balanceLabel.textAlignment = .center
            }
            
            private func setupLayout() {
                self.addSubview(self.abbreviationContainer)
                self.addSubview(self.companyImage)
                self.addSubview(self.balanceLabel)
                
                self.abbreviationContainer.addSubview(self.abbreviationLabel)
                
                self.abbreviationContainer.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().inset(10.0)
                    make.width.height.equalTo(self.imageSize)
                }
                
                self.companyImage.snp.makeConstraints { (make) in
                    make.edges.equalTo(self.abbreviationContainer)
                }
                
                self.abbreviationLabel.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.balanceLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.equalTo(self.companyImage.snp.bottom).offset(20.0)
                    make.bottom.equalToSuperview()
                }
            }
        }
    }
}
