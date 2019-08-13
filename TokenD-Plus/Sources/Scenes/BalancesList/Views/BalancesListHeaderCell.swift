import UIKit
import Nuke

extension BalancesList {
    
    public enum HeaderCell {
        
        public struct ViewModel: CellViewModel {
            let imageUrl: URL?
            let balance: String
            let cellIdentifier: Model.CellIdentifier
            
            public func setup(cell: Cell) {
                cell.balance = self.balance
                cell.imageUrl = self.imageUrl
            }
        }
        
        public class Cell: UITableViewCell {
            
            // MARK: - Public properties
            
            var balance: String? {
                get { return self.balanceLabel.text }
                set { self.balanceLabel.text = newValue }
            }
            
            var imageUrl: URL? {
                didSet {
                    guard let url = self.imageUrl else {
                        return
                    }
                    Nuke.loadImage(
                        with: url,
                        into: self.companyImage
                    )
                }
            }
            
            var cellIdentifier: Model.CellIdentifier?
            
            // MARK: - Private properties
            
            private let companyImage: UIImageView = UIImageView()
            private let balanceLabel: UILabel = UILabel()
            
            private let imageSize: CGFloat = 70.0
            private let sideInset: CGFloat = 15.0
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                self.setupView()
                self.setupImageView()
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
            
            private func setupImageView() {
                self.companyImage.backgroundColor = Theme.Colors.contentBackgroundColor
                self.companyImage.layer.cornerRadius = self.imageSize / 2
                self.companyImage.clipsToBounds = true
            }
            
            private func setupBalanceLabel() {
                self.balanceLabel.backgroundColor = Theme.Colors.contentBackgroundColor
                self.balanceLabel.font = Theme.Fonts.largeAssetFont
                self.balanceLabel.numberOfLines = 0
                self.balanceLabel.textAlignment = .center
            }
            
            private func setupLayout() {
                self.addSubview(self.companyImage)
                self.addSubview(self.balanceLabel)
                
                self.companyImage.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().inset(10.0)
                    make.width.height.equalTo(self.imageSize)
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
