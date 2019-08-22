import UIKit
import RxSwift
import Charts
import ActionsList

public protocol BalancesListDisplayLogic: class {
    typealias Event = BalancesList.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
    func displaySectionsUpdated(viewModel: Event.SectionsUpdated.ViewModel)
    func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel)
    func displayPieChartEntriesChanged(viewModel: Event.PieChartEntriesChanged.ViewModel)
    func displayPieChartBalanceSelected(viewModel: Event.PieChartBalanceSelected.ViewModel)
    func displayActionsDidChange(viewModel: Event.ActionsDidChange.ViewModel)
    func displayBuyAsk(viewModel: Event.BuyAsk.ViewModel)
}

extension BalancesList {
    public typealias DisplayLogic = BalancesListDisplayLogic
    
    @objc(BalancesListViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = BalancesList.Event
        public typealias Model = BalancesList.Model
        
        // MARK: - Private properties
        
        private let horizontalPicker: HorizontalPicker = HorizontalPicker()
        private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
        private let emptyView: UILabel = SharedViewsBuilder.createEmptyLabel()
        private let fab: UIButton = UIButton()
        private let button: UIBarButtonItem = UIBarButtonItem(
            image: Assets.plusIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        private let refreshControl: UIRefreshControl = UIRefreshControl()
        
        private var tabs: [Model.Tab] = []
        private var sections: [Model.SectionViewModel] = [] {
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
        
        private var actions: [ActionsListDefaultButtonModel] = []
        private var actionsList: ActionsListModel?
        private let disposeBag: DisposeBag = DisposeBag()
        
        private let sideInset: CGFloat = 25.0
        private let topInset: CGFloat = 25.0
        private let buttonSize: CGFloat = 65.0
        
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
            self.setupHorizontalPicker()
            self.setupFab()
            self.setupRefreshControl()
            self.setupTableView()
            self.setupEmptyLabel()
            self.setupNavBarItems()
            self.setupLayout()
            
            self.observeLanguageChanges()
            
            let request = Event.ViewDidLoad.Request()
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
                        let request = Event.RefreshInitiated.Request()
                        self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                            businessLogic.onRefreshInitiated(request: request)
                        })
                    }
                }
            )
        }
        
        private func showActions() {
            self.actionsList = self.fab.createActionsList()
            self.actions.forEach { (action) in
                self.actionsList?.add(action: action)
            }
            self.actionsList?.present()
        }
        
        private func updateContentOffset(offset: CGPoint) {
            if offset.y > 0 {
                self.routing?.showShadow()
                let topInset = self.topInset - offset.y
                let insetMultiplier: CGFloat = topInset > 0 ? 1 : 5
                let inset = topInset * insetMultiplier
                self.fab.snp.updateConstraints { (make) in
                    make.bottom.equalTo(self.view.safeArea.bottom).inset(inset)
                }
                UIView.animate(withDuration: 0.01, animations: {
                    self.fab.setNeedsLayout()
                    self.fab.layoutIfNeeded()
                })
            } else {
                self.routing?.hideShadow()
            }
        }
        
        private func findCell<CellViewModelType: CellViewAnyModel, CellType: UITableViewCell>(
            cellIdentifier: Model.CellIdentifier,
            cellViewModelType: CellViewModelType.Type,
            cellType: CellType.Type
            ) -> (vm: CellViewModelType, ip: IndexPath, cc: CellType?)? {
            
            for (sectionIndex, section) in self.sections.enumerated() {
                for (cellIndex, cell) in section.cells.enumerated() {
                    guard let chartCellViewModel = cell as? CellViewModelType else {
                        continue
                    }
                    
                    let indexPath = IndexPath(row: cellIndex, section: sectionIndex)
                    if let cell = self.tableView.cellForRow(at: indexPath) {
                        if let chartCell = cell as? CellType {
                            return (chartCellViewModel, indexPath, chartCell)
                        } else {
                            return nil
                        }
                    } else {
                        return (chartCellViewModel, indexPath, nil)
                    }
                }
            }
            
            return nil
        }
        
        private func setSelectedTabIfNeeded(index: Int?) {
            guard let index = index,
                index != self.horizontalPicker.selectedItemIndex else {
                    return
            }
            self.horizontalPicker.setSelectedItemAtIndex(index, animated: true)
        }
        
        // MARK: - Setup
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupHorizontalPicker() {
            self.horizontalPicker.backgroundColor = Theme.Colors.contentBackgroundColor
            self.horizontalPicker.tintColor = Theme.Colors.accentColor
        }
        
        private func setupNavBarItems() {
            self.button.rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    self?.showActions()
                })
                .disposed(by: self.disposeBag)
            //self.navigationItem.rightBarButtonItem = button
        }
        
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
            self.tableView.register(classes: [
                HeaderCell.ViewModel.self,
                BalanceCell.ViewModel.self,
                PieChartCell.ViewModel.self,
                AskCell.ViewModel.self
                ]
            )
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .none
            self.tableView.sectionFooterHeight = 0.0
            self.tableView.tableHeaderView = UIView(
                frame: CGRect(x: 0, y: 0, width: 0, height: 0.1)
            )
            self.tableView.estimatedRowHeight = UITableView.automaticDimension
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView
                .rx
                .contentOffset
                .asDriver()
                .drive(onNext: { [weak self] (offset) in
                    self?.updateContentOffset(offset: offset)
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupEmptyLabel() {
            
        }
        
        private func setupFab() {
            self.fab.backgroundColor = Theme.Colors.accentColor
            self.fab.tintColor = Theme.Colors.textOnAccentColor
            self.fab.layer.cornerRadius = self.buttonSize / 2
            self.fab.setImage(
                Assets.plusIcon.image,
                for: .normal
            )
            self.fab.layer.shadowColor = Theme.Colors.textOnMainColor.cgColor
            self.fab.layer.shadowOffset = CGSize(width: 3.5, height: 3.5)
            self.fab.layer.shadowOpacity = 0.25
            self.fab.layer.masksToBounds = false
            self.fab
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    self?.showActions()
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupLayout() {
            self.view.addSubview(self.horizontalPicker)
            self.view.addSubview(self.tableView)
            self.view.addSubview(self.fab)
            self.view.addSubview(self.emptyView)
            
            self.tableView.addSubview(self.refreshControl)
            
            self.horizontalPicker.snp.makeConstraints { (make) in
                make.leading.trailing.top.equalToSuperview()
            }
            
            self.tableView.snp.makeConstraints { (make) in
                make.top.equalTo(self.horizontalPicker.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
            
            self.emptyView.snp.makeConstraints { (make) in
                make.top.equalTo(self.horizontalPicker.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
            
            self.fab.snp.makeConstraints { (make) in
                make.trailing.equalToSuperview().inset(self.sideInset)
                make.bottom.equalTo(self.view.safeArea.bottom).inset(self.topInset)
                make.height.width.equalTo(self.buttonSize)
            }
        }
    }
}

extension BalancesList.ViewController: BalancesList.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.tabs = viewModel.tabs
        let items = self.tabs.map { (tab) -> HorizontalPicker.Item in
            return HorizontalPicker.Item(
                title: tab.name,
                enabled: true,
                onSelect: { [weak self] in
                    let request = Event.SelectedTab.Request(tabIdentifier: tab.identifier)
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onSelectedTab(request: request)
                    })
            })
        }
        self.horizontalPicker.items = items
    }
    
    public func displaySectionsUpdated(viewModel: Event.SectionsUpdated.ViewModel) {
        self.setSelectedTabIfNeeded(index: viewModel.selectedTabIndex)
        switch viewModel.type {
            
        case .sections(let sections):
            self.fab.isHidden = false
            self.emptyView.isHidden = true
            self.sections = sections
            
        case .empty(let text):
            self.fab.isHidden = true
            self.emptyView.text = text
            self.emptyView.isHidden = false
            self.sections = []
        }
    }
    
    public func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel) {
        switch viewModel {
            
        case .loaded:
            self.routing?.hideProgress()
            
        case .loading:
            self.routing?.showProgress()
        }
    }
    
    public func displayPieChartEntriesChanged(viewModel: Event.PieChartEntriesChanged.ViewModel) {
        
    }
    
    public func displayPieChartBalanceSelected(viewModel: Event.PieChartBalanceSelected.ViewModel) {
        guard let (chartViewModel, indexPath, cell) = self.findCell(
            cellIdentifier: .chart,
            cellViewModelType: BalancesList.PieChartCell.ViewModel.self,
            cellType: BalancesList.PieChartCell.View.self
            ) else {
                return
        }
        
        guard let chartCell = cell else {
            return
        }
        var udpdatedChartViewModel = chartViewModel
        udpdatedChartViewModel.chartViewModel = viewModel.pieChartViewModel
        udpdatedChartViewModel.legendCells = viewModel.legendCells
        udpdatedChartViewModel.setup(cell: chartCell)
        self.sections[indexPath.section].cells[indexPath.row] = udpdatedChartViewModel
    }
    
    public func displayActionsDidChange(viewModel: Event.ActionsDidChange.ViewModel) {
        
        self.actions = viewModel.models.map({ (action) -> ActionsListDefaultButtonModel in
            
            let actionModel = ActionsListDefaultButtonModel(
                localizedTitle: action.title,
                image: action.image,
                action: { [weak self] (_) in
                    self?.actionsList?.dismiss({
                        switch action.actionType {
                            
                        case .acceptRedeem:
                            self?.routing?.showAcceptRedeem()
                            
                        case .createRedeem:
                            self?.routing?.showCreateRedeem()
                            
                        case .receive:
                            self?.routing?.showReceive()
                            
                        case .send:
                            self?.routing?.showSendPayment()
                        }
                    })
                },
                isEnabled: true
            )
            actionModel.appearance.tint = Theme.Colors.accentColor
            return actionModel
        })
    }
    
    public func displayBuyAsk(viewModel: Event.BuyAsk.ViewModel) {
        self.routing?.showBuy(viewModel.ask)
    }
}

extension BalancesList.ViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.sections[indexPath.section].cells[indexPath.row]
        if let balancesModel = model as? BalancesList.BalanceCell.ViewModel {
            self.routing?.onBalanceSelected(balancesModel.balanceId)
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.sections[indexPath.section].cells[indexPath.row]
        
        if model as? BalancesList.HeaderCell.ViewModel != nil {
            return 120.0
        } else if model as? BalancesList.BalanceCell.ViewModel != nil {
            return 90.0
        } else if model as? BalancesList.AskCell.ViewModel != nil {
            return 115.0
        } else {
            return 44.0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.sections[indexPath.section].cells[indexPath.row]
        
        if model as? BalancesList.HeaderCell.ViewModel != nil {
            return 120.0
        } else if model as? BalancesList.BalanceCell.ViewModel != nil {
            return 90.0
        } else if model as? BalancesList.AskCell.ViewModel != nil {
            return 115.0
        } else {
            return 44.0
        }
    }
}

extension BalancesList.ViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.sections[indexPath.section].cells[indexPath.row]
        let cell = tableView.dequeueReusableCell(with: model, for: indexPath)
        
        if let chartCell = cell as? BalancesList.PieChartCell.View {
            chartCell.onChartBalanceSelected = { [weak self] (value) in
                let request = Event.PieChartBalanceSelected.Request(value: value)
                self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                    businessLogic.onPieChartBalanceSelected(request: request)
                })
            }
        } else if let askCell = cell as? BalancesList.AskCell.Cell,
            let askModel = model as? BalancesList.AskCell.ViewModel {
            askCell.onBuyAction = { [weak self] in
                let request = Event.BuyAsk.Request(id: askModel.askId)
                self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                    businessLogic.onBuyAsk(request: request)
                })
            }
        }
        return cell
    }
}
