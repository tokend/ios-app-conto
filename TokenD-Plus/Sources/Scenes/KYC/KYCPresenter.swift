import Foundation
import UIKit

public protocol KYCPresentationLogic {
    typealias Event = KYC.Event
    
    func presentViewDidLoad(response: Event.ViewDidLoad.Response)
    func presentAction(response: Event.Action.Response)
}

extension KYC {
    public typealias PresentationLogic = KYCPresentationLogic
    
    @objc(KYCPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = KYC.Event
        public typealias Model = KYC.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        public init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
        
        // MARK: - Private
        
        private func getFieldViewModels(
            _ fields: [Model.Field]
            ) -> [View.Field] {
            
            let fieldViewModels = fields.map { (field) -> View.Field in
                let fieldViewModel = View.Field(
                    fieldType: field.type,
                    title: field.type.viewModelTitle,
                    text: field.value,
                    placeholder: field.type.viewModelPlaceholder,
                    keyboardType: field.type.viewModelKeyboardType,
                    autocapitalize: .none,
                    autocorrection: .no,
                    secureInput: field.type.viewModelIsSecureInput
                )
                
                return fieldViewModel
            }
            
            return fieldViewModels
        }
    }
}

extension KYC.Presenter: KYC.PresentationLogic {
    
    public func presentViewDidLoad(response: Event.ViewDidLoad.Response) {
        let fields = self.getFieldViewModels(response.fields)
        let viewModel = Event.ViewDidLoad.ViewModel(fields: fields)
        self.presenterDispatch.display { displayLogic in
            displayLogic.displayViewDidLoad(viewModel: viewModel)
        }
    }
    
    public func presentAction(response: Event.Action.Response) {
        let viewModel: Event.Action.ViewModel
        switch response {
            
        case .loaded:
            viewModel = .loaded
            
        case .loading:
            viewModel = .loading
            
        case .failure(let error):
            viewModel = .failure(message: error.localizedDescription)
            
        case .success:
            viewModel = .success(message: Localized(.kyc_sent))
            
        case .validationError(let error):
            viewModel = .validationError(error.localizedDescription)
        }
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayAction(viewModel: viewModel)
        }
    }
}

extension KYC.Model.KYCError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        case .failedToBuildTransaction,
             .failedToEncodeData,
             .failedToFormBlob:
            
            return Localized(.failed_to_build_transaction)
            
            
        case .other(let error):
            return error.localizedDescription
        }
    }
}

extension KYC.Model.ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        case .emptyName:
            return Localized(.enter_first_name)
            
        case .emptySurname:
            return Localized(.enter_last_name)
        }
    }
}

extension KYC.Model.FieldType {
    var viewModelTitle: String {
        switch self {
            
        case .name:
            return Localized(.name)
            
        case .surname:
            return Localized(.surname)
        }
    }
    
    var viewModelPlaceholder: String {
        switch self {
        default:
            let title = self.viewModelTitle
            return Localized(
                .enter_t,
                replace: [
                    .enter_t_replace_title: title
                ]
            )
        }
    }
    
    var viewModelKeyboardType: UIKeyboardType {
        switch self {

        case .name, .surname:
            return .default
        }
    }
    
    var viewModelIsSecureInput: Bool {
        switch self {
            
        case .name, .surname:
            return false
        }
    }
}

