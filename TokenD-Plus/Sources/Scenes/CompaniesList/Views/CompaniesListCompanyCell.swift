import UIKit
import Nuke

extension CompaniesList {
    
    public enum CompanyCell {
        
        public struct ViewModel: CellViewModel {
            
            let companyColor: UIColor
            let companyImageUrl: URL
            let companyName: String
            let accountId: String
            
            public func setup(cell: View) {
                cell.companyColor = self.companyColor
                cell.companyImageUrl = self.companyImageUrl
                cell.companyName = self.companyName
            }
        }
        
        public class View: UITableViewCell {
            
            // MARK: - Public properties
            
            public var companyColor: UIColor? {
                get { return self.cardView.backgroundColor }
                set { self.cardView.backgroundColor = newValue }
            }
            
            public var companyImageUrl: URL? {
                didSet {
                    if let url = self.companyImageUrl {
                        Nuke.loadImage(
                            with: url,
                            into: self.companyImageView
                        )
                    } else {
                        Nuke.cancelRequest(for: self.companyImageView)
                    }
                }
            }
            
            public var companyName: String? {
                get { return self.companyNameLabel.text }
                set { self.companyNameLabel.text = newValue }
            }
            
            static public let cardSize: CGSize = CGSize(width: 125.0, height: 75.0)
            static public let logoSize: CGFloat = 50.0
            static public let sideInset: CGFloat = 20.0
            static public let topInset: CGFloat = 10.0
            
            // MARK: - Private properties
            
            private let cardView: UIView = UIView()
            private let companyImageView: UIImageView = UIImageView()
            private let amountLabel: UILabel = UILabel()
            private let companyNameLabel: UILabel = UILabel()
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                self.setupView()
                self.setupCardView()
                self.setupCompanyImageView()
                self.setupAmountLabel()
                self.setupCompanyNameLabel()
                self.setupLayout()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            // MARK: - Private
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
                self.selectionStyle = .none
                self.separatorInset = UIEdgeInsets(
                    top: 0.0,
                    left: View.sideInset * 2 + View.cardSize.width,
                    bottom: 0.0,
                    right: 0.0
                )
            }
            
            private func setupCardView() {
                self.cardView.layer.cornerRadius = 5.0
                self.cardView.layer.masksToBounds = true
            }
            
            private func setupCompanyImageView() {
                self.companyImageView.layer.cornerRadius = View.logoSize / 2.0
                self.companyImageView.layer.masksToBounds = true
                self.companyImageView.contentMode = .scaleAspectFit
                self.companyImageView.backgroundColor = Theme.Colors.contentBackgroundColor
            }
            
            private func setupAmountLabel() {
                self.amountLabel.backgroundColor = UIColor.clear
                self.amountLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.amountLabel.font = Theme.Fonts.largeTitleFont
                self.amountLabel.textAlignment = .left
                self.amountLabel.numberOfLines = 1
            }
            
            private func setupCompanyNameLabel() {
                self.companyNameLabel.backgroundColor = UIColor.clear
                self.companyNameLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.companyNameLabel.font = Theme.Fonts.plainTextFont
                self.companyNameLabel.textAlignment = .left
                self.companyNameLabel.numberOfLines = 1
            }
            
            private func setupLayout() {
                self.addSubview(self.cardView)
                self.cardView.addSubview(self.companyImageView)
                self.addSubview(self.amountLabel)
                self.addSubview(self.companyNameLabel)
                
                self.cardView.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(View.sideInset)
                    make.top.bottom.equalToSuperview().inset(View.topInset)
                    make.size.equalTo(View.cardSize)
                }
                
                self.companyImageView.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                    make.width.height.equalTo(View.logoSize)
                }
                
                self.amountLabel.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.cardView.snp.trailing).offset(View.sideInset)
                    make.trailing.equalToSuperview().offset(View.sideInset)
                    make.bottom.equalTo(self.cardView.snp.centerY).offset(-View.topInset / 2.0)
                }
                
                self.companyNameLabel.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.cardView.snp.trailing).offset(View.sideInset)
                    make.trailing.equalToSuperview().offset(View.sideInset)
                    make.top.equalTo(self.amountLabel.snp.bottom).offset(View.topInset)
                }
            }
        }
    }
}
