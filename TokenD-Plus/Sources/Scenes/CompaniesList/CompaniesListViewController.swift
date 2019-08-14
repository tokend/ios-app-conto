import UIKit
import RxSwift

public protocol CompaniesListDisplayLogic: class {
    typealias Event = CompaniesList.Event
    
    func displaySceneUpdated(viewModel: Event.SceneUpdated.ViewModel)
    func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel)
    func displayAddBusinessAction(viewModel: Event.AddBusinessAction.ViewModel)
    func displayCompanyChosen(viewModel: Event.CompanyChosen.ViewModel)
}

extension CompaniesList {
    public typealias DisplayLogic = CompaniesListDisplayLogic
    
    @objc(CompaniesListViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = CompaniesList.Event
        public typealias Model = CompaniesList.Model
        
        // MARK: - Private properties
        
        private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
        private let emptyView: EmptyView.View = EmptyView.View()
        private let refreshControl: UIRefreshControl = UIRefreshControl()
        private let addAccountItem: UIBarButtonItem = UIBarButtonItem(
            image: Assets.plusIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        
        private var companies: [CompanyCell.ViewModel] = [] {
            didSet {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                UIView.animate(withDuration: 0.5, animations: {
                    self.tableView.reloadData()
                })
            }
        }
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        deinit {
            self.onDeinit?(self)
        }
        
        // MARK: - Injections
        
        private var interactorDispatch: InteractorDispatch?
        private var routing: Routing?
        private var onDeinit: DeinitCompletion = nil
        
        public func inject(
            interactorDispatch: InteractorDispatch?,
            routing: Routing?,
            onDeinit: DeinitCompletion = nil
            ) {
            
            self.interactorDispatch = interactorDispatch
            self.routing = routing
            self.onDeinit = onDeinit
        }
        
        // MARK: - Overridden
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            self.setupTableView()
            self.setupAddAccountItem()
            self.setupEmptyView()
            self.setupRefreshControl()
            self.setupLayout()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func showCompaniesSreen(companies: [CompanyCell.ViewModel]) {
            self.companies = companies
            self.emptyView.isHidden = true
        }
        
        private func showEmptyScreen(message: String) {
            self.companies = []
            self.emptyView.message = message
            self.emptyView.showAddButton()
            self.navigationItem.rightBarButtonItem = self.addAccountItem
            self.emptyView.isHidden = false
        }
        
        private func showErrorScreen(message: String) {
            self.companies = []
            self.emptyView.message = message
            self.emptyView.hideAddButton()
            self.navigationItem.rightBarButtonItem = nil
            self.emptyView.isHidden = false
        }
        
        private func updateContentOffset(offset: CGPoint) {
            if offset.y > 0 {
                self.routing?.showShadow()
            } else {
                self.routing?.hideShadow()
            }
        }
        
        // MARK: - Setup
        
        private func setupRefreshControl() {
            self.refreshControl
                .rx
                .controlEvent(.valueChanged)
                .subscribe(onNext: { [weak self] (_) in
                    let request = Event.RefreshInitiated.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onRefreshInitiated(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupTableView() {
            self.tableView.backgroundColor = Theme.Colors.contentBackgroundColor
            self.tableView.separatorStyle = .none
            self.tableView.estimatedRowHeight = UITableView.automaticDimension
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.register(classes: [
                CompanyCell.ViewModel.self
                ]
            )
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.refreshControl = self.refreshControl
            self.tableView
                .rx
                .contentOffset
                .asDriver()
                .drive(onNext: { [weak self] (offset) in
                    self?.updateContentOffset(offset: offset)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupAddAccountItem() {
            self.addAccountItem
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    self?.routing?.onPresentQRCodeReader({ [weak self] (result) in
                        switch result {
                            
                        case .canceled:
                            break
                            
                        case .success(let accountId, _):
                            let request = Event.AddBusinessAction.Request(accountId: accountId)
                            self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                                businessLogic.onAddBusinessAction(request: request)
                            })
                        }
                    })
                })
                .disposed(by: self.disposeBag)
            self.navigationItem.rightBarButtonItem = self.addAccountItem
        }
        
        private func setupEmptyView() {
            self.emptyView.isHidden = true
            self.emptyView.onRefresh = { [weak self] in
                let request = Event.RefreshInitiated.Request()
                self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                    businessLogic.onRefreshInitiated(request: request)
                })
            }
            self.emptyView.onAddButtonClicked = { [weak self] in
                self?.routing?.onPresentQRCodeReader({ (result) in
                    switch result {
                        
                    case .canceled:
                        break
                        
                    case .success(let accountId, _):
                        let request = Event.AddBusinessAction.Request(accountId: accountId)
                        self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                            businessLogic.onAddBusinessAction(request: request)
                        })
                    }
                })
            }
        }
        
        private func setupLayout() {
            self.view.addSubview(self.tableView)
            self.view.addSubview(self.emptyView)
            
            self.tableView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            self.emptyView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension CompaniesList.ViewController: CompaniesList.DisplayLogic {
    
    public func displaySceneUpdated(viewModel: Event.SceneUpdated.ViewModel) {
        switch viewModel {
            
        case .companies(let companies):
            self.companies = companies
            self.emptyView.isHidden = true
            
        case .empty(let message):
            self.showEmptyScreen(message: message)
            
        case .error(let message):
            self.showErrorScreen(message: message)
        }
    }
    
    public func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel) {
        switch viewModel {
            
        case .loaded:
            self.routing?.hideLoading()
            
        case .loading:
            self.routing?.showLoading()
        }
    }
    
    public func displayAddBusinessAction(viewModel: Event.AddBusinessAction.ViewModel) {
        
        switch viewModel {
            
        case .error(let message):
            self.routing?.showError(message)
            
        case .success(let company):
            let completion: CompaniesList.AddCompanyCompletion = { (result) in
                switch result {
                    
                case .error:
                    break
                    
                case .success:
                    let request = Event.RefreshInitiated.Request()
                    self.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onRefreshInitiated(request: request)
                    })
                }
            }
            self.routing?.onAddCompany(
                company,
                completion
            )
        }
    }
    
    public func displayCompanyChosen(viewModel: Event.CompanyChosen.ViewModel) {
        self.routing?.onCompanyChosen(viewModel.model)
    }
}

extension CompaniesList.ViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.companies[indexPath.section]
        let request = Event.CompanyChosen.Request(accountId: model.accountId)
        self.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
            businessLogic.onCompanyChosen(request: request)
        })
    }
}

extension CompaniesList.ViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.companies.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.companies[indexPath.section]
        let cell = tableView.dequeueReusableCell(with: model, for: indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}
