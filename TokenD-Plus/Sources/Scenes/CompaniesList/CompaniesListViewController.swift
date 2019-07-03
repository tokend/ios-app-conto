import UIKit

public protocol CompaniesListDisplayLogic: class {
    typealias Event = CompaniesList.Event
    
    func displaySceneUpdated(viewModel: Event.SceneUpdated.ViewModel)
    func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel)
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
        
        private var companies: [CompanyCell.ViewModel] = []
        
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
            self.setupEmptyView()
            self.setupLayout()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func setupTableView() {
            self.tableView.backgroundColor = Theme.Colors.contentBackgroundColor
            self.tableView.separatorStyle = .none
            self.tableView.register(classes: [
                CompanyCell.ViewModel.self
                ]
            )
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
        
        private func setupEmptyView() {
            self.emptyView.isHidden = true
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
            self.emptyView.isHidden = true
            self.companies = companies
            self.tableView.reloadData()
            
        case .empty(let message):
            self.emptyView.message = message
            self.emptyView.isHidden = false
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
}

extension CompaniesList.ViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.companies[indexPath.section]
        self.routing?.onCompanyChosen(model.accountId, model.companyName)
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
}
