import UIKit
import RxSwift
import Charts
import ActionsList

public protocol BalancesListDisplayLogic: class {
    typealias Event = BalancesList.Event
    
    func displaySectionsUpdated(viewModel: Event.SectionsUpdated.ViewModel)
    func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel)
    func displayPieChartEntriesChanged(viewModel: Event.PieChartEntriesChanged.ViewModel)
    func displayPieChartBalanceSelected(viewModel: Event.PieChartBalanceSelected.ViewModel)
}

extension BalancesList {
    public typealias DisplayLogic = BalancesListDisplayLogic
    
    @objc(BalancesListViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = BalancesList.Event
        public typealias Model = BalancesList.Model
        
        // MARK: - Private properties
        
        private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
        private let fab: UIButton = UIButton()
        private let button: UIBarButtonItem = UIBarButtonItem(
            image: Assets.plusIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        private let refreshControl: UIRefreshControl = UIRefreshControl()
        
        private var sections: [Model.SectionViewModel] = []
        
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
            self.setupRefreshControl()
            self.setupTableView()
            self.setupNavBarItems()
            self.setupLayout()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func showActions() {
            self.actionsList = self.button.createActionsList(
                withColor: Theme.Colors.clear,
                font: nil,
                delegate: nil
            )
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
        
        // MARK: - Setup
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
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
            self.refreshControl.tintColor = Theme.Colors.contentBackgroundColor
            self.refreshControl
                .rx
                .controlEvent(.valueChanged)
                .subscribe(onNext: { [weak self] (_) in
                    self?.refreshControl.endRefreshing()
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
                PieChartCell.ViewModel.self
                ]
            )
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .none
            self.tableView.sectionFooterHeight = 0.0
            self.tableView
                .rx
                .contentOffset
                .asDriver()
                .drive(onNext: { [weak self] (offset) in
                    self?.updateContentOffset(offset: offset)
                })
                .disposed(by: self.disposeBag)
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
            self.view.addSubview(self.tableView)
            self.view.addSubview(self.fab)
            
            self.tableView.addSubview(self.refreshControl)
            
            self.tableView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
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
    
    public func displaySectionsUpdated(viewModel: Event.SectionsUpdated.ViewModel) {
        self.sections = viewModel.sections
        self.tableView.reloadData()
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
}

extension BalancesList.ViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.sections[indexPath.section].cells[indexPath.row]
        if let balancesModel = model as? BalancesList.BalanceCell.ViewModel {
            self.routing?.onBalanceSelected(balancesModel.balanceId)
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
        }
        return cell
    }
}
