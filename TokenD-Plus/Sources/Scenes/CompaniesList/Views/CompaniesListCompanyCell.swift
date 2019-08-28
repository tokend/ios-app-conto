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
            
            // MARK: - Private
            
            private var initialImageLoad: Bool = true
            
            // MARK: - Public properties
            
            public var companyColor: UIColor? {
                get { return nil }
                set {
                    self.companyAbbreviationLabel.textColor = newValue
                }
            }
            
            public var companyImageUrl: URL? {
                didSet {
                    if let url = self.companyImageUrl {
                        Nuke.loadImage(
                            with: url,
                            into: self.companyImageView,
                            completion: { [weak self] (response, error) in
                                if error != nil {
                                    self?.companyImageView.isHidden = true
                                    self?.imageContainer.isHidden = false
                                } else {
                                    self?.companyImageView.isHidden = false
                                    self?.imageContainer.isHidden = true
                                }
                                self?.initialImageLoad = false
                        })
                    } else {
                        if self.initialImageLoad {
                            self.companyImageView.isHidden = true
                            self.imageContainer.isHidden = false
                            Nuke.cancelRequest(for: self.companyImageView)
                        }
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
            
            
            private let iconSize: CGFloat = 75.0
            private let sideInset: CGFloat = 20.0
            private let topInset: CGFloat = 7.5
            
            // MARK: - Private properties
            
            private let imageContainer: UIView = UIView()
            private let abbreviationContainer: UIView = UIView()
            private let companyImageView: UIImageView = UIImageView()
            private let companyAbbreviationLabel: UILabel = UILabel()
            private let companyNameLabel: UILabel = UILabel()
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                self.setupView()
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
            }
            
            private func setupImageContainer() {
                self.imageContainer.layer.cornerRadius = self.iconSize / 2
                self.imageContainer.layer.borderWidth = 0.25
                self.imageContainer.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupAbbreviationContainer() {
                self.abbreviationContainer.backgroundColor = Theme.Colors.contentBackgroundColor
                self.abbreviationContainer.layer.cornerRadius = self.iconSize / 2
            }
            
            private func setupAbbreviationLabel() {
                self.companyAbbreviationLabel.backgroundColor = UIColor.clear
                self.companyAbbreviationLabel.font = Theme.Fonts.hugeTitleFont
                self.companyAbbreviationLabel.textAlignment = .center
            }
            
            private func setupCompanyImageView() {
                self.companyImageView.backgroundColor = Theme.Colors.contentBackgroundColor
                self.companyImageView.contentMode = .scaleAspectFit
                self.companyImageView.clipsToBounds = true
                self.companyImageView.layer.cornerRadius = self.iconSize / 2
                self.companyImageView.layer.borderWidth = 0.25
                self.companyImageView.layer.borderColor = Theme.Colors.separatorOnContentBackgroundColor.cgColor
            }
            
            private func setupCompanyNameLabel() {
                self.companyNameLabel.backgroundColor = UIColor.clear
                self.companyNameLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.companyNameLabel.font = Theme.Fonts.largeTitleFont
                self.companyNameLabel.textAlignment = .left
                self.companyNameLabel.numberOfLines = 0
                self.companyNameLabel.lineBreakMode = .byTruncatingMiddle
            }
            
            private func setupLayout() {
                self.addSubview(self.imageContainer)
                self.addSubview(self.companyImageView)
                self.addSubview(self.companyNameLabel)
                
                self.imageContainer.addSubview(self.abbreviationContainer)
                self.abbreviationContainer.addSubview(self.companyAbbreviationLabel)
                
                self.imageContainer.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().inset(self.sideInset)
                    make.top.bottom.equalToSuperview().inset(self.topInset)
                    make.height.width.equalTo(self.iconSize)
                }
                
                self.companyImageView.snp.makeConstraints { (make) in
                    make.edges.equalTo(self.imageContainer)
                }
                
                self.abbreviationContainer.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.companyAbbreviationLabel.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.companyNameLabel.snp.makeConstraints { (make) in
                    make.leading.equalTo(self.imageContainer.snp.trailing).offset(self.sideInset)
                    make.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.centerY.equalTo(self.companyImageView)
                }
            }
        }
    }
}
