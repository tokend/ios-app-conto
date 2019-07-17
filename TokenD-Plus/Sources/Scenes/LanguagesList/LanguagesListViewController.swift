import UIKit

public protocol LanguagesListDisplayLogic: class {
    typealias Event = LanguagesList.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
}

extension LanguagesList {
    public typealias DisplayLogic = LanguagesListDisplayLogic
    
    @objc(LanguagesListViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = LanguagesList.Event
        public typealias Model = LanguagesList.Model
        
        // MARK: - Private properties
        
        private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
        
        private var cells: [LanguageCell.ViewModel] = []
        
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
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        private func setupTableView() {
            self.tableView.backgroundColor = Theme.Colors.containerBackgroundColor
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.register(classes: [
                LanguageCell.ViewModel.self
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

extension LanguagesList.ViewController: LanguagesList.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        
    }
}

extension LanguagesList.ViewController: UITableViewDataSource {
    
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

extension LanguagesList.ViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
