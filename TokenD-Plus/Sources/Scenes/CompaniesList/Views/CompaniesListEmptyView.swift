import Foundation
import UIKit
import SnapKit
import RxSwift

extension CompaniesList {
    enum EmptyView {
        struct Model {
            let message: String
        }
        
        struct ViewModel {
            let message: String
            
            func setup(_ view: View) {
                view.message = self.message
            }
        }
        
        class View: UIView {
            
            // MARK: - Public properties
            
            public var message: String? {
                get { return self.emptyLabel.text }
                set { self.emptyLabel.text = newValue }
            }
            
            public var onAddButtonClicked: (() -> Void)?
            public var onRefresh: (() -> Void)?
            
            // MARK: - Private properties
            
            private let tableView: UITableView = UITableView()
            private let refreshControl: UIRefreshControl = UIRefreshControl()
            private let emptyLabel: UILabel = UILabel()
            private let addCompanyButton: UIButton = UIButton()
            
            private let buttonWidth: CGFloat = 90.0
            private let buttonHeight: CGFloat = 40.0
            
            private let disposeBag: DisposeBag = DisposeBag()
            
            // MARK: - Override
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                self.commonInit()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            // MARK: - Private
            
            private func commonInit() {
                self.setupView()
                self.setupTableView()
                self.setupRefreshControl()
                self.setupEmptyLabel()
                self.setupAddButton()
                self.setupLayout()
            }
            
            // MARK: - Setup
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
            }
            
            private func setupTableView() {
                self.tableView.separatorStyle = .none
                self.tableView.refreshControl = self.refreshControl
            }
            
            private func setupRefreshControl() {
                self.refreshControl
                    .rx
                    .controlEvent(.valueChanged)
                    .subscribe(onNext: { [weak self] _ in
                        self?.onRefresh?()
                        self?.refreshControl.endRefreshing()
                    })
                    .disposed(by: self.disposeBag)
            }
            
            private func setupEmptyLabel() {
                self.emptyLabel.textColor = Theme.Colors.sideTextOnContainerBackgroundColor
                self.emptyLabel.font = Theme.Fonts.smallTextFont
                self.emptyLabel.textAlignment = .center
                self.emptyLabel.lineBreakMode = .byWordWrapping
                self.emptyLabel.numberOfLines = 0
            }
            
            private func setupAddButton() {
                self.addCompanyButton.backgroundColor = Theme.Colors.accentColor
                self.addCompanyButton.setTitleColor(
                    Theme.Colors.textOnAccentColor,
                    for: .normal
                )
                self.addCompanyButton.setTitle(
                    Localized(.add),
                    for: .normal
                )
                self.addCompanyButton.titleLabel?.font = Theme.Fonts.actionButtonFont
                self.addCompanyButton
                    .rx
                    .tap
                    .asDriver()
                    .drive(onNext: { [weak self] _ in
                        self?.onAddButtonClicked?()
                    })
                    .disposed(by: self.disposeBag)
            }
            
            private func setupLayout() {
                self.addSubview(self.tableView)
                self.addSubview(self.emptyLabel)
                self.addSubview(self.addCompanyButton)
                
                self.tableView.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                
                self.emptyLabel.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().offset(-30)
                    make.leading.trailing.equalToSuperview().inset(15)
                }
                
                self.addCompanyButton.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().offset(30)
                    make.width.equalTo(self.buttonWidth)
                    make.height.equalTo(self.buttonHeight)
                }
            }   
        }
    }
}
