import UIKit
import RxSwift

protocol SideMenuDisplayLogic: class {
    func displayViewDidLoad(viewModel: SideMenu.Event.ViewDidLoad.ViewModel)
}

extension SideMenu {
    typealias DisplayLogic = SideMenuDisplayLogic
    
    class ViewController: UIViewController {
        
        // MARK: - Private properties
        
        private let headerView: HeaderView = HeaderView()
        private let separatorView: UIView = UIView()
        private let tableView: UITableView  = UITableView(
            frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0),
            style: .grouped
        )
        private let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
        private let disposeBag: DisposeBag = DisposeBag()
        
        private var sections: [[SideMenuTableViewCell.Model]] = [] {
            didSet {
                self.reloadTable()
            }
        }
        
        // MARK: - Injections
        
        private var interactorDispatch: InteractorDispatch?
        private var routing: Routing?
        
        func inject(interactorDispatch: InteractorDispatch?, routing: Routing?) {
            self.interactorDispatch = interactorDispatch
            self.routing = routing
        }
        
        // MARK: - Overridden
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.setupView()
            
            self.observeLanguageChanges()
            
            let request = SideMenu.Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func observeLanguageChanges() {
            NotificationCenterUtil.instance.addObserver(
                forName: Notification.Name("LCLLanguageChangeNotification"),
                using: { [weak self] notification in
                    DispatchQueue.main.async {
                        let request = Event.LanguageChanged.Request()
                        self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                            businessLogic.onViewDidLoad(request: request)
                        })
                    }
                }
            )
        }
        
        private func handleAction(identifier: Model.Identifier) {
            switch identifier {
                
            case .balances:
                self.routing?.showBalances()
                
            case .companies:
                self.routing?.showCompanies()
                
            case .contribute:
                self.routing?.showContribute()
                
            case .movements:
                self.routing?.showMovements()
                
            case .settings:
                self.routing?.showSettings()
            }
        }
        
        private func reloadTable() {
            self.tableView.reloadData()
        }
        
        private func updateHeaderWithModel(_ headerModel: Model.HeaderModel) {
            self.headerView.iconImage = headerModel.icon
            self.headerView.title = headerModel.title
            self.headerView.subTitle = headerModel.subTitle
        }
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.mainColor
            
            self.setupHeaderView()
            self.setupSeparatorView()
            self.setupTapGestureRecognizer()
            self.setupTableView()
            
            self.setupLayout()
        }
        
        private func setupHeaderView() {
            
        }
        
        private func setupSeparatorView() {
            self.separatorView.backgroundColor = Theme.Colors.separatorOnMainColor
            self.separatorView.isUserInteractionEnabled = false
        }
        
        private func setupTableView() {
            self.tableView.register(classes: [SideMenuTableViewCell.Model.self])
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.rowHeight = 50.0
            self.tableView.separatorStyle = .none
            self.tableView.backgroundColor = Theme.Colors.contentBackgroundColor
            self.tableView.sectionHeaderHeight = 0
            self.tableView.sectionFooterHeight = 0
            self.tableView.sectionHeaderHeight = UITableView.automaticDimension
            
            let footerView = UIView()
            footerView.backgroundColor = Theme.Colors.contentBackgroundColor
            self.tableView.tableFooterView = footerView
        }
        
        private func setupTapGestureRecognizer() {
            self.tapRecognizer
                .rx
                .event
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    self?.routing?.showReceive()
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupLayout() {
            self.view.addSubview(self.headerView)
            self.view.addSubview(self.separatorView)
            self.view.addSubview(self.tableView)
            
            self.headerView.addGestureRecognizer(self.tapRecognizer)
            
            self.headerView.snp.makeConstraints { (make) in
                make.top.equalTo(self.view.safeArea.top)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(100.0)
            }
            
            self.separatorView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(self.headerView.snp.bottom)
                make.height.equalTo(1.0)
            }
            
            self.tableView.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(self.separatorView.snp.bottom)
            }
        }
    }
}

// MARK: - DisplayLogic

extension SideMenu.ViewController: SideMenu.DisplayLogic {
    
    func displayViewDidLoad(viewModel: SideMenu.Event.ViewDidLoad.ViewModel) {
        self.updateHeaderWithModel(viewModel.header)
        self.sections = viewModel.sections
    }
}

// MARK: - UITableViewDelegate

extension SideMenu.ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellModel = self.sections[indexPath.section][indexPath.row]
        self.handleAction(identifier: cellModel.identifier)
    }
}

// MARK: - UITableViewDataSource

extension SideMenu.ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return nil }
        
        let headerView = UITableViewHeaderFooterView()
        let separatorView = UIView()
        headerView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.top.equalToSuperview()
        }
        separatorView.backgroundColor = Theme.Colors.sideMenuSectionSeparatorColor
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else { return 0 }
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.sections[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(with: model, for: indexPath)
        
        return cell
    }
}
