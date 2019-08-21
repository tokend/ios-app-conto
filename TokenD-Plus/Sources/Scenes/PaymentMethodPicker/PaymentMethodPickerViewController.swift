import UIKit

public protocol PaymentMethodPickerDisplayLogic: class {
    typealias Event = PaymentMethodPicker.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
}

extension PaymentMethodPicker {
    public typealias DisplayLogic = PaymentMethodPickerDisplayLogic
    
    @objc(PaymentMethodPickerViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = PaymentMethodPicker.Event
        public typealias Model = PaymentMethodPicker.Model
        
        // MARK: - Private properties
        
        private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
        private var methods: [MethodCell.ViewModel] = []
        
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
        
        // MARK: - Private
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupTableView() {
            self.tableView.backgroundColor = Theme.Colors.containerBackgroundColor
            self.tableView.register(classes: [
                MethodCell.ViewModel.self
                ]
            )
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
        
        private func setupLayout() {
            self.view.addSubview(self.tableView)
            
            self.tableView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension PaymentMethodPicker.ViewController: PaymentMethodPicker.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.methods = viewModel.methods
        self.tableView.reloadData()
    }
}

extension PaymentMethodPicker.ViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let method = self.methods[indexPath.row]
        self.dismiss(
            animated: true,
            completion: { [weak self] in
                self?.routing?.onPaymentMethodPicked(method.asset)
        })
    }
}

extension PaymentMethodPicker.ViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.methods.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.methods[indexPath.row]
        let cell = tableView.dequeueReusableCell(with: model, for: indexPath)
        
        return cell
    }
}
