import UIKit
import RxSwift

public protocol TabBarContainerDisplayLogic: class {
    typealias Event = TabBarContainer.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
}

public protocol TabBarContainerTabBarProtocol {
    var view: UIView { get }
    var height: CGFloat { get }
    
    func setSelectedTabWithIdentifier(_ identifier: TabBarContainer.TabIdentifier)
}

public protocol TabBarContainerContentProtocol {
    var viewController: UIViewController { get }
    
    func setContentWithIdentifier(_ identifier: TabBarContainer.TabIdentifier)
}

extension TabBarContainer {
    public typealias DisplayLogic = TabBarContainerDisplayLogic
    public typealias TabBarProtocol = TabBarContainerTabBarProtocol
    public typealias ContentProtocol = TabBarContainerContentProtocol
    public typealias TabIdentifier = String
    
    @objc(TabBarContainerViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = TabBarContainer.Event
        public typealias Model = TabBarContainer.Model
        
        // MARK: - Private properties
        
        private var content: ContentProtocol? {
            didSet {
                if oldValue?.viewController != self.content?.viewController {
                    oldValue?.viewController.removeFromParent()
                    self.setupContent()
                }
            }
        }
        
        private var tabBar: TabBarProtocol? {
            didSet {
                if oldValue?.view != self.tabBar?.view {
                    oldValue?.view.removeFromSuperview()
                    self.setupTabBar()
                }
            }
        }
        
        private var viewDidAppear: Bool = false
        
        private let conatinerTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
        
        private let barTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
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
            self.setupContainerTapGestureRecognizer()
            self.setupBarTapGestureRecognizer()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendSyncRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        public override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + .milliseconds(100), execute: {
                    self.viewDidAppear = true
            })
        }
        
        // MARK: - Public
        
        public func setSelectedContentWithIdentifier(idetifier: TabIdentifier) {
            self.tabBar?.setSelectedTabWithIdentifier(idetifier)
            self.content?.setContentWithIdentifier(idetifier)
        }
        
        public func showTabBar() {
            self.tabBar?.view.isUserInteractionEnabled = true
            self.tabBar?.view.snp.remakeConstraints({ (make) in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.safeArea.bottom)
            })
            if self.viewDidAppear {
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                })
            }
        }
        
        public func hideTabBar() {
            self.tabBar?.view.isUserInteractionEnabled = false
            if self.viewDidAppear {
                self.tabBar?.view.snp.remakeConstraints({ (make) in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalTo(self.view.safeArea.bottom)
                })
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
        
        // MARK: - Private
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupTabBar() {
            guard let tabBar = self.tabBar?.view else { return }
            tabBar.addGestureRecognizer(self.barTapRecognizer)
            self.view.addSubview(tabBar)
            self.layoutTabBar()
            self.updateSubviews()
        }
        
        private func setupContent() {
            guard let viewController = self.content?.viewController else { return }
            viewController.view.isUserInteractionEnabled = true
            viewController.view.addGestureRecognizer(self.conatinerTapRecognizer)
            self.addChild(
                viewController,
                to: self.view,
                layoutFulledge: false
            )
            self.updateSubviews()
        }
        
        private func setupContainerTapGestureRecognizer() {
            self.conatinerTapRecognizer.cancelsTouchesInView = false
            self.conatinerTapRecognizer.numberOfTapsRequired = 1
            self.conatinerTapRecognizer.delegate = self
            self.conatinerTapRecognizer
                .rx
                .event
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + .milliseconds(250),
                        execute: {
                            self?.tabBar?.view.isUserInteractionEnabled = true
                    })
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupBarTapGestureRecognizer() {
            self.barTapRecognizer.cancelsTouchesInView = false
            self.barTapRecognizer.numberOfTapsRequired = 1
            self.barTapRecognizer.delaysTouchesBegan = true
            self.tabBar?.view.addGestureRecognizer(self.barTapRecognizer)
        }
        
        private func layoutTabBar() {
            guard let tabBar = self.tabBar?.view else { return }
            
            tabBar.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.safeArea.bottom)
            }
        }
        
        private func updateSubviews() {
            if let tabBar = self.tabBar?.view {
                self.view.bringSubviewToFront(tabBar)
            }
            
            guard let viewController = self.content?.viewController else { return }
            
            self.view.sendSubviewToBack(viewController.view)
            if let tabBar = self.tabBar?.view {
                viewController.view.snp.remakeConstraints { (make) in
                    make.leading.trailing.top.equalToSuperview()
                    make.bottom.equalTo(tabBar.snp.top)
                }
            } else {
                viewController.view.snp.remakeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
}

extension TabBarContainer.ViewController: TabBarContainer.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.content = viewModel.sceneContent.content
        self.tabBar = viewModel.sceneContent.tabBar
        self.navigationItem.title = viewModel.sceneContent.title
    }
}

extension TabBarContainer.ViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        self.barTapRecognizer.cancelsTouchesInView = true
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(300),
            execute: {
                self.barTapRecognizer.cancelsTouchesInView = false
        })
        print("shoulde begin")
        return true
    }
}
