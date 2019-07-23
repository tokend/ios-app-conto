import UIKit
import Nuke

extension CompaniesList {
    
    public enum CompanyCell {
        
        public struct ViewModel: CellViewModel {
            
            let companyColor: UIColor
            let companyImageUrl: URL?
            let companyName: String
            let companyAbbreviation: String
            let accountId: String
            
            public func setup(cell: View) {
                cell.companyColor = self.companyColor
                cell.companyImageUrl = self.companyImageUrl
                cell.companyName = self.companyName
                cell.companyAbbreviation = self.companyAbbreviation
            }
        }
        
        public class View: UITableViewCell {
            
            // MARK: - Public properties
            
            public var companyColor: UIColor? {
                get { return self.cardView.backgroundColor }
                set {
                    self.cardView.backgroundColor = newValue
                    self.companyAbbreviationLabel.textColor = newValue
                }
            }
            
            public var companyImageUrl: URL? {
                didSet {
                    if let url = self.companyImageUrl {
                        self.abbreviationContainer.isHidden = true
                        Nuke.loadImage(
                            with: url,
                            into: self.companyImageView
                        )
                    } else {
                        self.abbreviationContainer.isHidden = false
                        Nuke.cancelRequest(for: self.companyImageView)
                    }
                }
            }
            
            public var companyAbbreviation: String? {
                get { return self.companyAbbreviationLabel.text }
                set { self.companyAbbreviationLabel.text = newValue }
            }
            
            public var companyName: String? {
                get { return self.companyNameLabel.text }
                set { self.companyNameLabel.text = newValue }
            }
            
            static public let cardSize: CGSize = CGSize(width: 125.0, height: 75.0)
            static public let logoSize: CGFloat = 50.0
            static public let sideInset: CGFloat = 20.0
            static public let topInset: CGFloat = 7.5
            
            // MARK: - Private properties
            
            private let cardView: UIView = UIView()
            private let imageContainer: UIView = UIView()
            private let abbreviationContainer: UIView = UIView()
            private let companyImageView: UIImageView = UIImageView()
            private let companyAbbreviationLabel: UILabel = UILabel()
            private let companyNameLabel: UILabel = UILabel()
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                self.setupView()
                self.setupCardView()
                self.setupImageContainer()
                self.setupAbbreviationContainer()
                self.setupAbbreviationLabel()
                self.setupCompanyImageView()
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
            
            private func setupImageContainer() {
                self.imageContainer.backgroundColor = Theme.Colors.contentBackgroundColor
                self.imageContainer.layer.cornerRadius = View.logoSize / 2
            }
            
            private func setupAbbreviationContainer() {
                self.abbreviationContainer.backgroundColor = Theme.Colors.contentBackgroundColor
                self.abbreviationContainer.layer.cornerRadius = View.logoSize / 2
                self.abbreviationContainer.isHidden = true
            }
            
            private func setupAbbreviationLabel() {
                self.companyAbbreviationLabel.backgroundColor = UIColor.clear
                self.companyAbbreviationLabel.font = Theme.Fonts.hugeTitleFont
                self.companyAbbreviationLabel.textAlignment = .center
            }
            
            private func setupCompanyImageView() {
                self.companyImageView.layer.cornerRadius = View.logoSize / 2.0
                self.companyImageView.layer.masksToBounds = true
                self.companyImageView.clipsToBounds = true
                self.companyImageView.contentMode = .scaleAspectFit
                self.companyImageView.backgroundColor = Theme.Colors.contentBackgroundColor
            }
            
            private func setupCompanyNameLabel() {
                self.companyNameLabel.backgroundColor = UIColor.clear
                self.companyNameLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.companyNameLabel.font = Theme.Fonts.largeTitleFont
                self.companyNameLabel.textAlignment = .left
                self.companyNameLabel.numberOfLines = 1
            }
            
            private func setupLayout() {
                self.addSubview(self.cardView)
                self.cardView.addSubview(self.imageContainer)
                self.imageContainer.addSubview(self.companyImageView)
                self.imageContainer.addSubview(self.abbreviationContainer)
                self.abbreviationContainer.addSubview(self.companyAbbreviationLabel)
                
                self.addSubview(self.companyNameLabel)
                
                self.cardView.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(View.sideInset)
                    make.top.bottom.equalToSuperview().inset(View.topInset)
                    make.size.equalTo(View.cardSize)
                }
                
                
                self.imageContainer.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                    make.width.height.equalTo(View.logoSize)
                }
                
                self.companyImageView.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.abbreviationContainer.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.companyAbbreviationLabel.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.companyNameLabel.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.cardView.snp.trailing).offset(View.sideInset)
                    make.trailing.equalToSuperview().offset(View.sideInset)
                    make.top.centerY.equalTo(self.companyImageView)
                }
            }
        }
    }
}
