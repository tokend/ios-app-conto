import Foundation

public enum SendPaymentAmount {
    
    // MARK: -
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

public extension SendPaymentAmount.Model {
    typealias Ask = AtomicSwap.Model.Ask
    
    class SceneModel {
        public var selectedBalance: BalanceDetails?
        public var senderFee: FeeModel?
        public var recipientAddress: String?
        public var resolvedRecipientId: String?
        public var description: String?
        public var amount: Decimal = 0.0
        public let operation: Operation
        public let feeType: FeeType
        
        init(
            feeType: FeeType,
            operation: Operation,
            recipientAddress: String? = nil
            ) {
            
            self.operation = operation
            self.recipientAddress = recipientAddress
            self.feeType = feeType
        }
    }
    
    struct ViewConfig {
        let recipientAppearence: RecipientAppearence
        let descriptionIsHidden: Bool
        let actionButtonTitle: NSAttributedString
        let pickerIsAvailable: Bool
        let balanceTitle: String
    }
    
    struct SceneViewModel {
        let selectedBalance: BalanceDetailsViewModel?
        let recipientAddress: String?
        let amount: Decimal
        let amountValid: Bool
    }
    
    struct BalanceDetails {
        public let assetCode: String
        public let assetName: String
        public let balance: Decimal
        public let balanceId: String
    }
    
    struct BalanceDetailsViewModel {
        public let asset: String
        public let balance: String
        public let balanceId: String
    }
    
    struct FeeModel {
        public let asset: String
        public let fixed: Decimal
        public let percent: Decimal
    }
    
    struct SendPaymentModel {
        public let senderBalanceId: String
        public let assetName: String
        public let amount: Decimal
        public let recipientNickname: String
        public let recipientAccountId: String
        public let senderFee: FeeModel
        public let recipientFee: FeeModel
        public let description: String
        public let reference: String
    }
    
    struct SendWithdrawModel {
        public let senderBalance: BalanceDetails
        public let assetName: String
        public let amount: Decimal
        public let senderFee: FeeModel
    }
    
    struct ShowRedeemModel {
        let redeemRequest: String
        let amount: Decimal
        let assetName: String
    }
    
    struct AskModel {
        let ask: Ask
        let amount: Decimal
    }
    
    struct AtomicSwapPaymentUrl {
        let url: URL
    }
    
    struct ShowRedeemViewModel {
        let redeemRequest: String
        let amount: String
    }
    
    enum Operation {
        case handleSend
        case handleWithdraw
        case handleRedeem
        case handleAtomicSwap(Ask)
    }
    
    enum FeeType {
        case payment
        case offer
        case withdraw
    }
    
    enum RecipientAppearence {
        case hidden
        case text(String)
    }
    
    struct FeeOverviewModel {
        let asset: String
    }
}

// MARK: - Events

extension SendPaymentAmount.Event {
    
    public typealias Model = SendPaymentAmount.Model
    
    struct ViewDidLoad {
        struct Request {}
        
        struct Response {
            let sceneModel: Model.SceneModel
            let amountValid: Bool
        }
        
        struct ViewModel {
            let recipientInfo: String
            let sceneModel: Model.SceneViewModel
        }
    }
    
    struct LoadBalances {
        struct Request {}
        enum Response {
            case loading
            case loaded
            case failed(Error)
            case succeeded(sceneModel: Model.SceneModel, amountValid: Bool)
        }
        
        enum ViewModel {
            case loading
            case loaded
            case failed(errorMessage: String)
            case succeeded(Model.SceneViewModel)
        }
    }
    
    struct SelectBalance {
        struct Request {}
        
        struct Response {
            let balances: [Model.BalanceDetails]
        }
        
        struct ViewModel {
            let balances: [Model.BalanceDetailsViewModel]
        }
    }
    
    struct BalanceSelected {
        struct Request {
            let balanceId: String
        }
        
        struct Response {
            let sceneModel: Model.SceneModel
            let amountValid: Bool
        }
        
        struct ViewModel {
            let sceneModel: Model.SceneViewModel
        }
    }
    
    struct EditAmount {
        struct Request {
            let amount: Decimal
        }
        
        struct Response {
            let amountValid: Bool
        }
        
        struct ViewModel {
            let amountValid: Bool
        }
    }
    
    struct DescriptionUpdated {
        struct Request {
            let description: String?
        }
    }
    
    struct SubmitAction {
        struct Request {}
    }
    
    struct WithdrawAction {
        enum Response {
            case loading
            case loaded
            case failed(PaymentAction.SendError)
            case succeeded(Model.SendWithdrawModel)
        }
        
        enum ViewModel {
            case loading
            case loaded
            case failed(errorMessage: String)
            case succeeded(Model.SendWithdrawModel)
        }
    }
    
    struct PaymentAction {
        enum Response {
            case loading
            case loaded
            case failed(SendError)
            case succeeded(Model.SendPaymentModel)
        }
        
        enum ViewModel {
            case loading
            case loaded
            case failed(errorMessage: String)
            case succeeded(Model.SendPaymentModel)
        }
    }
    
    struct RedeemAction {
        enum Response {
            case loading
            case loaded
            case failed(RedeemError)
            case succeeded(Model.ShowRedeemModel)
        }
        
        enum ViewModel {
            case loading
            case loaded
            case failed(errorMessage: String)
            case succeeded(Model.ShowRedeemViewModel)
        }
    }
    
    public struct AtomicSwapBuyAction {
        public enum Response {
            case loading
            case loaded
            case failed(AtomicSwapError)
            case succeeded(Model.AtomicSwapPaymentUrl)
        }
        
        public enum ViewModel {
            case loading
            case loaded
            case failed(errorMessage: String)
            case succeeded(Model.AtomicSwapPaymentUrl)
        }
    }
    
    struct FeeOverviewAvailability {
        struct Response {
            let available: Bool
        }
        typealias ViewModel = Response
    }
    
    struct FeeOverviewAction {
        struct Request {}
        struct Response {
            let asset: String
            let feeType: Int32
        }
        typealias ViewModel = Response
    }
}

extension SendPaymentAmount.Event.PaymentAction {
    
    enum SendError: Error, LocalizedError {
        case emptyAmount
        case emptyRecipientAddress
        case failedToLoadFees(SendPaymentAmountFeeLoaderResult.FeeLoaderError)
        case failedToResolveRecipientAddress(RecipientAddressResolverResult.AddressResolveError)
        case insufficientFunds
        case noBalance
        case other(Error)
        
        // MARK: - LocalizedError
        
        var errorDescription: String? {
            switch self {
            case .emptyAmount:
                return Localized(.empty_amount)
            case .emptyRecipientAddress:
                return Localized(.empty_recipient_address)
            case .failedToLoadFees(let error):
                let message = error.localizedDescription
                return Localized(
                    .failed_to_load_fees,
                    replace: [
                        .failed_to_load_fees_replace_message: message
                    ]
                )
                
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

extension SendPaymentAmount.Event.RedeemAction {
    
    public enum RedeemError: Error, LocalizedError {
        case emptyAmount
        case insufficientFunds
        case noBalance
        case failedToDecodeAccountId(AccountId)
        case failedToDecodeBalanceId(BalanceId)
        case failedToSignTransaction
        case failedToGetAssetData
        case failedToGetTransactionSignature
        case other(Error)
        
        // MARK: - LocalizedError
        
        public var errorDescription: String? {
            switch self {
                
            case .emptyAmount:
                return Localized(.empty_amount)
                
            case .insufficientFunds:
                return Localized(.insufficient_funds)
                
            case .noBalance:
                return Localized(.no_balance)
                
            case .failedToDecodeAccountId(let accountId):
                let id = accountId.rawValue
                return Localized(
                    .failed_to_decode_account_id,
                    replace: [
                        .failed_to_decode_account_id_replace_id: id
                    ]
                )
            case .failedToDecodeBalanceId(let balanceId):
                let id = balanceId.rawValue
                return Localized(
                    .failed_to_decode_balance_id,
                    replace: [
                        .failed_to_decode_balance_id_replace_id: id
                    ]
                )
                
            case .failedToGetAssetData:
                return Localized(.failed_to_get_asset_data)
                
            case .failedToGetTransactionSignature:
                return Localized(.failed_to_fetch_transaction_signature)
                
            case .failedToSignTransaction:
                return Localized(.failed_to_sign_transaction)
                
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
    
    enum BalanceId: String {
        case senderBalanceId
    }
    
    enum AccountId: String {
        case recipientAccountId
        case senderAccountId
    }
}

extension SendPaymentAmount.Event.AtomicSwapBuyAction {
    
    public enum AtomicSwapError: Error, LocalizedError {
        case emptyAmount
        case bidMoreThanAsk
        case failedToFecthAskId
        case askIsNotFound
        case failedToDecodeSourceAccountId
        case failedToBuildTransaction
        case failedToSendTransaction
        case failedToFetchCreateBidRequest
        case createBidRequestIsNotFound
        case externalDetailsAreNotFound
        case paymentIsRejected
        case paymentUrlIsInvalid
        case other(Error)
        
        // MARK: - LocalizedError
        
        public var errorDescription: String? {
            switch self {
                
            case .emptyAmount:
                return Localized(.empty_amount)
                
            case .bidMoreThanAsk:
                return Localized(.amount_is_too_big)
                
            case .askIsNotFound:
                return Localized(.ask_is_not_found)
                
            case .createBidRequestIsNotFound:
                return Localized(.create_bid_request_is_not_found)
                
            case .externalDetailsAreNotFound:
                return Localized(.external_details_are_not_found)
                
            case .failedToBuildTransaction:
                return Localized(.failed_to_build_transaction)
                
            case .failedToDecodeSourceAccountId:
                return Localized(.failed_to_decode_account_id)
                
            case .failedToFecthAskId:
                return Localized(.failed_to_fetch_ask_id)
                
            case .failedToFetchCreateBidRequest:
                return Localized(.failed_to_fetch_create_bid_request)
                
            case .failedToSendTransaction:
                return Localized(.failed_to_send_transaction)
                
            case .other(let error):
                return error.localizedDescription
                
            case .paymentIsRejected:
                return Localized(.payment_rejected)
                
            case .paymentUrlIsInvalid:
                return Localized(.payment_url_is_invalid)
            }
        }
    }
}


// MARK: -

extension SendPaymentAmount.Model.BalanceDetails: Equatable {
    public static func ==(
        left: SendPaymentAmount.Model.BalanceDetails,
        right: SendPaymentAmount.Model.BalanceDetails
        ) -> Bool {
        
        return left.balanceId == right.balanceId
    }
}

extension SendPaymentAmount.Model.ViewConfig {
    
    static func sendPaymentViewConfig(recipient: String) -> SendPaymentAmount.Model.ViewConfig {
        let actionButtonTitle = NSAttributedString(
            string: Localized(.confirm),
            attributes: [
                .font: Theme.Fonts.actionButtonFont,
                .foregroundColor: Theme.Colors.textOnAccentColor
            ]
        )
        
        let recipeintText = Localized(
            .to,
            replace: [
                .to_replace_address : recipient
            ]
        )
        return SendPaymentAmount.Model.ViewConfig(
            recipientAppearence: .text(recipeintText),
            descriptionIsHidden: false,
            actionButtonTitle: actionButtonTitle,
            pickerIsAvailable: true,
            balanceTitle: Localized(.balance_colon)
        )
    }
    
    static func withdrawViewConfig() -> SendPaymentAmount.Model.ViewConfig {
        let actionButtonTitle = NSAttributedString(
            string: Localized(.continue_capitalized),
            attributes: [
                .font: Theme.Fonts.actionButtonFont,
                .foregroundColor: Theme.Colors.textOnAccentColor
            ]
        )
        
        return SendPaymentAmount.Model.ViewConfig(
            recipientAppearence: .hidden,
            descriptionIsHidden: true,
            actionButtonTitle: actionButtonTitle,
            pickerIsAvailable: true,
            balanceTitle: Localized(.balance_colon)
        )
    }
    
    static func redeemViewConfig(business: String) -> SendPaymentAmount.Model.ViewConfig {
        let actionButtonTitle = NSAttributedString(
            string: Localized(.continue_capitalized),
            attributes: [
                .font: Theme.Fonts.actionButtonFont,
                .foregroundColor: Theme.Colors.textOnAccentColor
            ]
        )
        let businessText = Localized(
            .for_code,
            replace: [
                .for_code_replace_code: business
            ]
        )
        return SendPaymentAmount.Model.ViewConfig(
            recipientAppearence: .text(businessText),
            descriptionIsHidden: true,
            actionButtonTitle: actionButtonTitle,
            pickerIsAvailable: true,
            balanceTitle: Localized(.balance_colon)
        )
    }
    
    static func atomicSwapViewConfig() -> SendPaymentAmount.Model.ViewConfig {
        let actionButtonTitle = NSAttributedString(
            string: Localized(.continue_capitalized),
            attributes: [
                .font: Theme.Fonts.actionButtonFont,
                .foregroundColor: Theme.Colors.textOnAccentColor
            ]
        )
        
        return SendPaymentAmount.Model.ViewConfig(
            recipientAppearence: .hidden,
            descriptionIsHidden: true,
            actionButtonTitle: actionButtonTitle,
            pickerIsAvailable: false,
            balanceTitle: Localized(.available_for_buy)
        )
    }
}
