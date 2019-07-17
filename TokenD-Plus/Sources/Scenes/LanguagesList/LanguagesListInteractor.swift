import Foundation

public protocol LanguagesListBusinessLogic {
    typealias Event = LanguagesList.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
}

extension LanguagesList {
    public typealias BusinessLogic = LanguagesListBusinessLogic
    
    @objc(LanguagesListInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = LanguagesList.Event
        public typealias Model = LanguagesList.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        
        // MARK: -
        
        public init(presenter: PresentationLogic) {
            self.presenter = presenter
        }
    }
}

extension LanguagesList.Interactor: LanguagesList.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        let english = Model.Language(
            name: "English",
            code: "en"
        )
        let russian = Model.Language(
            name: "Русский",
            code: "ru"
        )
        let ukrainian = Model.Language(
            name: "Українська",
            code: "uk-UA"
        )
        let cells: [Model.Language] = [english, russian, ukrainian]
        let response = Event.ViewDidLoad.Response(languages: cells)
        self.presenter.presentViewDidLoad(response: response)
    }
}
