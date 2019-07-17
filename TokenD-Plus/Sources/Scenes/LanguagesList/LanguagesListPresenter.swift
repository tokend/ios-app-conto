import Foundation

public protocol LanguagesListPresentationLogic {
    typealias Event = LanguagesList.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
}

extension LanguagesList {
    public typealias PresentationLogic = LanguagesListPresentationLogic
    
    @objc(LanguagesListPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = LanguagesList.Event
        public typealias Model = LanguagesList.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension LanguagesList.Presenter: LanguagesList.PresentationLogic {
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let cells = response.languages.map { (model) -> LanguagesList.LanguageCell.ViewModel in
            return LanguagesList.LanguageCell.ViewModel(
                title: model.name,
                code: model.code
            )
        }
        let viewModel = Event.ViewDidLoad.ViewModel(languages: cells)
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
}
