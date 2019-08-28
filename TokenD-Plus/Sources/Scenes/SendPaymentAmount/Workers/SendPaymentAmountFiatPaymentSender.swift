import Foundation
import TokenDSDK
import TokenDWallet
import RxCocoa

public enum SendPaymentAmountPaymentSenderResult {
    case success(SendPaymentAmount.Model.AtomicSwapPaymentType)
    case error(Swift.Error)
}
public protocol SendPaymentAmountPaymentSenderProtocol {
    func sendPayment(
        transaction: TransactionModel,
        completion: @escaping (SendPaymentAmountPaymentSenderResult) -> Void
    )
}

extension SendPaymentAmount {
    public typealias PaymentSenderProtocol = SendPaymentAmountPaymentSenderProtocol
    
    public class FiatPaymentSender {
        
        // MARK: - Private properties
        
        private let api: TransactionsApi
        private let keychainDataProvider: KeychainDataProviderProtocol
        
        // MARK: -
        
        public init(
            api: TransactionsApi,
            keychainDataProvider: KeychainDataProviderProtocol
            ) {
            
            self.api = api
            self.keychainDataProvider = keychainDataProvider
        }
        
        // MARK: - Private
        
        private func sendTransaction(
            _ transaction: TransactionModel,
            shouldSign: Bool = true,
            completion: @escaping (SendPaymentAmountPaymentSenderResult) -> Void
            ) throws {
            
            if shouldSign {
                try transaction.addSignature(signer: self.keychainDataProvider.getKeyData())
            }
            self.api.sendFiatPayment(
                envelope: transaction.getEnvelope().toXdrBase64String()
            ) { (result) in
                switch result {
                    
                case .success(let paymentType):
                    guard let url = URL(string: response.data.attributes.payUrl) else {
                        completion(.error(Event.AtomicSwapBuyAction.AtomicSwapError.paymentUrlIsInvalid))
                        return
                    }
                    completion(.success(paymentType))
                    
                case .failure(let error):
                    completion(.error(error))
                }
            }
        }
    }
}

extension SendPaymentAmount.FiatPaymentSender: SendPaymentAmount.PaymentSenderProtocol {
    
    public func sendPayment(
        transaction: TransactionModel,
        completion: @escaping (SendPaymentAmountPaymentSenderResult) -> Void
        ) {
        
        try? self.sendTransaction(transaction, completion: completion)
    }
}
