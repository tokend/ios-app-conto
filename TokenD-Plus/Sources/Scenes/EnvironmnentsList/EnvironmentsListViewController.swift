import UIKit

public protocol EnvironmentsListDisplayLogic: class {
    typealias Event = EnvironmentsList.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
    func displayEnvironmentChanged(viewModel: Event.EnvironmentChanged.ViewModel)
}

extension EnvironmentsList {
    public typealias DisplayLogic = EnvironmentsListDisplayLogic
    
    @objc(EnvironmentsListViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = EnvironmentsList.Event
        public typealias Model = EnvironmentsList.Model
        
        // MARK: - Private properties
        
        private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
        
        private var cells: [EnvironmentCell.ViewModel] = []
        
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
            self.setupLayout()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.containerBackgroundColor
        }
        
        private func setupTableView() {
            self.tableView.backgroundColor = Theme.Colors.containerBackgroundColor
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.register(classes: [
                EnvironmentCell.ViewModel.self
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

extension EnvironmentsList.ViewController: EnvironmentsList.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.cells = viewModel.environments
        self.tableView.reloadData()
    }
    
    public func displayEnvironmentChanged(viewModel: Event.EnvironmentChanged.ViewModel) {
        switch viewModel {
        case .changed:
            self.routing?.onEnvironmentChanged()
            
        case .alreadyInThisEnvironment(let message):
            self.routing?.showMessage(message)
        }
    }
}

extension EnvironmentsList.ViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.cells.count == 0 ? 0 : 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.cells[indexPath.row]
        let cell = tableView.dequeueReusableCell(with: model, for: indexPath)
        return cell
    }
}

extension EnvironmentsList.ViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let model = self.cells[indexPath.row]
        
        let request = Event.EnvironmentChanged.Request(environment: model.environment)
        self.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
            businessLogic.onEnvironmentChanged(request: request)
        })
    }
}
