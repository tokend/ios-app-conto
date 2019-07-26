import UIKit
import RxSwift

public protocol AtomicSwapDisplayLogic: class {
    typealias Event = AtomicSwap.Event
    
    func displaySceneDidUpdate(viewModel: Event.SceneDidUpdate.ViewModel)
    func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel)
}

extension AtomicSwap {
    public typealias DisplayLogic = AtomicSwapDisplayLogic
    
    @objc(AtomicSwapViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = AtomicSwap.Event
        public typealias Model = AtomicSwap.Model
        
        // MARK: - Private properties
        
        private let tableView: UITableView = UITableView(
            frame: .zero,
            style: .grouped
        )
        private let refreshControl: UIRefreshControl = UIRefreshControl()
        private let emptyView: UILabel = SharedViewsBuilder.createEmptyLabel()
        private let disposeBag: DisposeBag = DisposeBag()
        
        private var cells: [CellViewAnyModel] = [] {
            didSet {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                UIView.animate(
                    withDuration: 0.5,
                    animations: {
                        self.tableView.reloadData()
                })
            }
        }
        
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
            
            self.setupView()
            self.setupTableView()
            self.setupRefreshControl()
            self.setupLayout()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.containerBackgroundColor
        }
        
        private func setupTableView() {
            self.tableView.backgroundColor = Theme.Colors.contentBackgroundColor
            self.tableView.register(classes: [
                    AskCell.ViewModel.self,
                    InfoCell.ViewModel.self
                ]
            )
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.estimatedRowHeight = UITableView.automaticDimension
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.separatorStyle = .none
        }
        
        private func setupRefreshControl() {
            self.refreshControl
                .rx
                .controlEvent(.valueChanged)
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    let request = Event.RefreshInitiated.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onRefreshInitiated(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
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

extension AtomicSwap.ViewController: AtomicSwap.DisplayLogic {
    
    public func displaySceneDidUpdate(viewModel: Event.SceneDidUpdate.ViewModel) {
        switch viewModel {
            
        case .cells(let cells):
            self.emptyView.isHidden = true
            self.cells = cells
            
        case .empty(let message):
            self.emptyView.text = message
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

extension AtomicSwap.ViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.cells[indexPath.section]
        if model as? AtomicSwap.AskCell.ViewModel != nil {
            return 120.0
        } else if model as? AtomicSwap.InfoCell.ViewModel != nil {
            return 90.0
        } else {
            return 44.0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.cells[indexPath.section]
        if model as? AtomicSwap.AskCell.ViewModel != nil {
            return 120.0
        } else if model as? AtomicSwap.InfoCell.ViewModel != nil {
            return 90.0
        } else {
            return 44.0
        }
    }
}

extension AtomicSwap.ViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.cells.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.cells[indexPath.section]
        let cell = self.tableView.dequeueReusableCell(with: model, for: indexPath)
        
        if let askCell = cell as? AtomicSwap.AskCell.View {
            askCell.onAction = {
                
            }
        }
        return cell
    }
}
