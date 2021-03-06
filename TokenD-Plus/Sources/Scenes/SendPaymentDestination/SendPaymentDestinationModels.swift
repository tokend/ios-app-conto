import UIKit

public enum SendPaymentDestination {
    
    // MARK: - Typealiases
    
    public typealias DeinitCompletion = ((_ vc: UIViewController) -> Void)?
    public typealias QRCodeReaderCompletion = (_ result: Model.QRCodeReaderResult) -> Void
    public typealias SelectContactEmailCompletion = (_ email: String) -> Void
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

public extension SendPaymentDestination.Model {
    typealias FeeModel = SendPaymentAmount.Model.FeeModel
    typealias FeeType = SendPaymentAmount.Model.FeeType
    typealias BalanceDetails = SendPaymentAmount.Model.BalanceDetails
    
    class SceneModel {
        
        // MARK: - Public properties
        
        public var selectedBalance: BalanceDetails?
        public var senderFee: FeeModel?
        public var recipientAddress: String?
        public var resolvedRecipientId: String?
        public var description: String?
        public var amount: Decimal = 0.0
        public let operation: Operation
        public let feeType: FeeType
        public let accountEmail: String
        
        // MARK: -
        
        init(
            feeType: FeeType,
            operation: Operation,
            recipientAddress: String? = nil,
            accountEmail: String
            ) {
            
            self.operation = operation
            self.recipientAddress = recipientAddress
            self.feeType = feeType
            self.accountEmail = accountEmail
        }
    }
    
    struct SendDestinationModel {
        public let recipientNickname: String
        public let recipientAccountId: String
        public let isAccountExists: Bool
    }
    
    struct SendWithdrawModel {
        let senderBalanceId: String
        let asset: String
        let amount: Decimal
        let recipientNickname: String
        let recipientAddress: String
        let senderFee: FeeModel
    }
    
    enum QRCodeReaderResult {
        case canceled
        case success(value: String, metadataType: String)
    }
    
    struct ContactModel {
        let name: String
        let email: String
    }
    
    struct SectionModel {
        let title: String
        let cells: [ContactModel]
    }
    
    struct SectionViewModel {
        let title: String
        let cells: [CellViewAnyModel]
    }
    
    struct ViewConfig {
        let recipientAddressFieldPlaceholder: String
        let actionTitle: String
        let actionButtonTitle: NSAttributedString
        let contactsAreHidden: Bool
    }
    
    enum Operation {
        case handleSend
        case handleWithdraw
    }
    
    enum LoadingStatus {
        case loaded
        case loading
    }
}

// MARK: - Events

extension SendPaymentDestination.Event {
    public typealias Model = SendPaymentDestination.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request {}
        public struct Response {}
        public struct ViewModel {}
    }
    
    public struct EditRecipientAddress {
        public struct Request {
            let address: String?
        }
    }
    
    public struct SelectedContact {
        public struct Request {
            public let email: String
        }
        public enum Response {
            case failure(message: String)
            case success(String)
        }
        public typealias ViewModel = Response
    }
    
    public struct ScanRecipientQRAddress {
        public struct Request {
            public let qrResult: Model.QRCodeReaderResult
        }
        
        public enum Response {
            case canceled
            case failed(FailedReason)
            case succeeded(String)
        }
        
        public enum ViewModel {
            case canceled
            case failed(errorMessage: String)
            case succeeded(String)
        }
    }
    
    public struct SubmitAction {
        public struct Request {}
    }
    
    public struct PaymentAction {
       public enum Response {
            case destination(Model.SendDestinationModel)
            case nonExistedDestination(Model.SendDestinationModel)
            case error(DestinationError)
        }
        
        public enum ViewModel {
            case destination(Model.SendDestinationModel)
            case nonExistedDestination(Model.SendDestinationModel)
            case error(String)
        }
    }
    
    public struct WithdrawAction {
        public enum Response {
            case failed(SendError)
            case succeeded(Model.SendWithdrawModel)
        }
        
        public enum ViewModel {
            case failed(errorMessage: String)
            case succeeded(Model.SendWithdrawModel)
        }
    }
    
    public struct ContactsUpdated {
        public enum Response {
            case sections([Model.SectionModel])
            case error(String)
            case empty
        }
        
        public struct ViewModel {
            let sections: [Model.SectionViewModel]
        }
    }
    
    public struct LoadingStatusDidChange {
        public typealias Response =  Model.LoadingStatus
        public typealias ViewModel = Response
    }
}

extension SendPaymentDestination.Event.ScanRecipientQRAddress {
    
    public enum FailedReason: Error, LocalizedError {
        case invalidEmail
        case other(Error)
        case permissionDenied
        
        // MARK: - LocalizedError
        
        public var errorDescription: String? {
            switch self {
            case .invalidEmail:
                return Localized(.there_is_not_any_user_with_such_an_email_was_found)
            case .other(let error):
                let message = error.localizedDescription
                return Localized(
                    .request_error,
                    replace: [
                        .request_error_replace_message: message
                    ]
                )
            case .permissionDenied:
                return Localized(.permission_denied)
            }
        }
    }
}

extension SendPaymentDestination.Model.ViewConfig {
    
    static func sendPayment() -> SendPaymentDestination.Model.ViewConfig {
        let actionButtonTitle = NSAttributedString(
            string: Localized(.continue_capitalized),
            attributes: [
                .font: Theme.Fonts.actionButtonFont,
                .foregroundColor: Theme.Colors.textOnAccentColor
            ]
        )
        return SendPaymentDestination.Model.ViewConfig(
            recipientAddressFieldPlaceholder: Localized(.enter_email),
            actionTitle: Localized(.enter_email),
            actionButtonTitle: actionButtonTitle,
            contactsAreHidden: false
        )
    }
    
    static func sendWithdraw() -> SendPaymentDestination.Model.ViewConfig {
        let actionButtonTitle = NSAttributedString(
            string: Localized(.confirm),
            attributes: [
                .font: Theme.Fonts.actionButtonFont,
                .foregroundColor: Theme.Colors.textOnAccentColor
            ]
        )
        return SendPaymentDestination.Model.ViewConfig(
            recipientAddressFieldPlaceholder: Localized(.enter_destination_address),
            actionTitle: Localized(.enter_destination_address),
            actionButtonTitle: actionButtonTitle,
            contactsAreHidden: true
        )
    }
}

extension SendPaymentDestination.Event.PaymentAction {
    
    public enum DestinationError: Error, LocalizedError {
        case emptyRecipientAddress
        case failedToResolveRecipientAddress(RecipientAddressResolverResult.AddressResolveError)
        case itIsForbiddenToSendToYourself
        case other(Error)
        
        // MARK: - LocalizedError
        
        public var errorDescription: String? {
            switch self {
            case .emptyRecipientAddress:
                return Localized(.empty_recipient_address)
                
            case .failedToResolveRecipientAddress(let error):
                let message = error.localizedDescription
                return Localized(
                    .failed_to_resolve_recipient_address,
                    replace: [
                        .failed_to_resolve_recipient_address_replace_message: message
                    ]
                )
                
            case .itIsForbiddenToSendToYourself:
                return Localized(.you_cannot_send_payment_to_yourself)
                
            case .other(let error):
                let message = error.localizedDescription
                return Localized(
                    .request_error,
                    replace: [
                        .request_error_replace_message: message
                    ]
                )
            }
        }
    }
}

extension SendPaymentDestination.Event.WithdrawAction {
    public enum SendError: Error, LocalizedError {
        case emptyAmount
        case emptyRecipientAddress
        case failedToFetchFee
        case failedToResolveRecipientAddress(RecipientAddressResolverResult.AddressResolveError)
        case insufficientFunds
        case noBalance
        case other(Error)
        
        // MARK: - LocalizedError
        
        public var errorDescription: String? {
            switch self {
            case .emptyAmount:
                return Localized(.empty_amount)
            case .emptyRecipientAddress:
                return Localized(.empty_recipient_address)
            case .failedToFetchFee:
                return Localized(.failed_to_fetch_fees)
            case .failedToResolveRecipientAddress(let error):
                let message = error.localizedDescription
                return Localized(
                    .failed_to_resolve_recipient_address,
                    replace: [
                        .failed_to_resolve_recipient_address_replace_message: message
                    ]
                )
                
            case .insufficientFunds:
                return Localized(.insufficient_funds)
            case .noBalance:
                return Localized(.no_balance)
            case .other(let error):
                let message = error.localizedDescription
                return Localized(
                    .request_error,
                    replace: [
                        .request_error_replace_message: message
                    ]
                )
            }
        }
    }
}

extension SendPaymentDestination.ContactsFetcherResult.FetchError: LocalizedError {
    
    public var errorDescription: String? {
        switch  self {
        case .other(let error):
            return error.localizedDescription
            
        case .permissionIsNotGranted:
            return Localized(.permission_for_contacts_denied)
        }
    }
}
