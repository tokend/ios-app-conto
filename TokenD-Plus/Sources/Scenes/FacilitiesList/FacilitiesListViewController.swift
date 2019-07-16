import UIKit

public protocol FacilitiesListDisplayLogic: class {
    typealias Event = FacilitiesList.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
}

extension FacilitiesList {
    public typealias DisplayLogic = FacilitiesListDisplayLogic
    
    @objc(FacilitiesListViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = FacilitiesList.Event
        public typealias Model = FacilitiesList.Model
        
        // MARK: - Private properties
        
        private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
        
        private var sections: [Model.SectionViewModel] = []
        
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
            self.setupLayout()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func setupTableView() {
            self.tableView.backgroundColor = Theme.Colors.containerBackgroundColor
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.register(classes: [
                    FacilityCell.ViewModel.self
                ]
            )
            self.tableView.estimatedRowHeight = 44.0
            self.tableView.rowHeight = UITableView.automaticDimension
        }
        
        private func setupLayout() {
            self.view.addSubview(self.tableView)
            
            self.tableView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension FacilitiesList.ViewController: FacilitiesList.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.sections = viewModel.sections
        self.tableView.reloadData()
    }
}

extension FacilitiesList.ViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.sections[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCell(with: model, for: indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }
}

extension FacilitiesList.ViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let model = self.sections[indexPath.section].items[indexPath.row]
        switch model.type {
            
        case .acceptRedeem:
            self.routing?.showAcceptRedeem()
            
        case .companies:
            self.routing?.showCompanies()
            
        case .redeem:
            self.routing?.showCreateRedeem()
            
        case .settings:
            self.routing?.showSettings()
        }
    }
}
