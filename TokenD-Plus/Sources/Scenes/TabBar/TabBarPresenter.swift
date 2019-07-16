import Foundation

public protocol TabBarPresentationLogic {
    typealias Event = TabBar.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
    func presentTabWasSelected(response: Event.TabWasSelected.Response)
    func presentAction(response: Event.Action.Response)
    func presentShowActionsList(response: Event.ShowActionsList.Response)
}

extension TabBar {
    public typealias PresentationLogic = TabBarPresentationLogic
    
    @objc(TabBarPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = TabBar.Event
        public typealias Model = TabBar.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension TabBar.Presenter: TabBar.PresentationLogic {
    
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
    
    public func presentTabWasSelected(response: Event.TabWasSelected.Response) {
        let viewModel = response
        self.presenterDispatch.display { (display) in
            display.displayTabWasSelected(viewModel: viewModel)
        }
    }
    
    public func presentAction(response: Event.Action.Response) {
        let viewModel = response
        self.presenterDispatch.display { (display) in
            display.displayAction(viewModel: viewModel)
        }
    }
    
    public func presentShowActionsList(response: Event.ShowActionsList.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayShowActionsList(viewModel: viewModel)
        }
    }
}
