import Foundation

public enum AcceptRedeem {
    
    public enum Model {}
}

extension AcceptRedeem.Model {
    
    public struct RedeemModel {
        let senderAccountId: String
        let senderBalanceId: String
        let assetName: String
        let inputAmount: Decimal
        let precisedAmount: UInt64
        let salt: UInt64
        let minTimeBound: UInt64
        let maxTimeBound: UInt64
        let hintWrapped: Data
        let signature: Data
    }
    
    public struct FeeModel {
        let asset: String
        let fixed: Decimal
        let percent: Decimal
    }
    
    public enum AcceptRedeemError: Error, LocalizedError {
        case failedToFetchDecodeRedeemRequest
        case failedToDecodeSenderAccountId
        case failedToFetchSenderAccount
        case failedToDecodeRedeemAsset
        case attempToRedeemForeignAsset
        case failedToFindSenderBalance
        case failedToDecodeSignature
        case other(Error)
        
        public var errorDescription: String? {
            switch self {
                
            case .attempToRedeemForeignAsset:
                return Localized(.you_cannot_accept_redeem_of_the_asset_that_you_do_not_own)
                
            case .failedToFetchDecodeRedeemRequest:
                return Localized(.invalid_redeem_request)
                
            case .failedToDecodeSenderAccountId:
                return Localized(.invalid_sender_account_id)
                
            case .failedToFetchSenderAccount:
                return Localized(.failed_to_fetch_sender_account)
                
            case .failedToDecodeRedeemAsset:
                return Localized(.invalid_redeem_asset)
                
            case .failedToFindSenderBalance:
                return Localized(.failed_to_fetch_sender_balance)
                
            case .failedToDecodeSignature:
                return Localized(.failed_to_fetch_transaction_signature)
                
            case .other(let error):
                return error.localizedDescription
            }
        }

    }
}
