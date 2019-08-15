import Foundation

public protocol PhoneNumberPresentationLogic {
    typealias Event = PhoneNumber.Event
    
}

extension PhoneNumber {
    public typealias PresentationLogic = PhoneNumberPresentationLogic
    
    @objc(PhoneNumberPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = PhoneNumber.Event
        public typealias Model = PhoneNumber.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension PhoneNumber.Presenter: PhoneNumber.PresentationLogic {
    
}
