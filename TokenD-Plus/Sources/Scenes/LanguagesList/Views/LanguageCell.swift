import RxCocoa
import RxSwift
import SnapKit
import UIKit

extension LanguagesList {
    
    enum LanguageCell {
        struct ViewModel: CellViewModel {
            
            let title: String
            let code: String
            
            func setup(cell: View) {
                cell.title = self.title
            }
        }
        
        class View: UITableViewCell {
            
            // MARK: - Private properties
            
            private let disposeBag = DisposeBag()
            
            private let titleLabel: UILabel = UILabel()
            
            private let sideInset: CGFloat = 15.0
            private let topInset: CGFloat = 10.0
            private let iconSize: CGFloat = 24.0
            
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
                super.init(coder: aDecoder)
                
                self.commonInit()
            }
            
            // MARK: - Private
            
            private func commonInit() {
                self.setupView()
                self.setupTitleLabel()
                
                self.setupLayout()
            }
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
            }
            
            private func setupTitleLabel() {
                self.titleLabel.font = Theme.Fonts.largePlainTextFont
                self.titleLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.titleLabel.textAlignment = .left
            }
            
            private func setupLayout() {
                self.addSubview(self.titleLabel)
                
                self.titleLabel.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.top.bottom.equalToSuperview().inset(self.topInset)
                }
            }
        }
    }
}
