import Foundation
import TokenDSDK
import TokenDWallet
import RxCocoa

public enum PaymentMethodPaymentSenderResult {
    case success(PaymentMethod.Model.AtomicSwapPaymentUrl)
    case error(Swift.Error)
}
public protocol PaymentMethodPaymentSenderProtocol {
    func sendPayment(
        transaction: TransactionModel,
        completion: @escaping (PaymentMethodPaymentSenderResult) -> Void
    )
}

extension PaymentMethod {
    public typealias PaymentSenderProtocol = PaymentMethodPaymentSenderProtocol
    
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
            completion: @escaping (PaymentMethodPaymentSenderResult) -> Void
            ) throws {
            
            if shouldSign {
                try transaction.addSignature(signer: self.keychainDataProvider.getKeyData())
            }
            self.api.sendFiatPayment(
                envelope: transaction.getEnvelope().toXdrBase64String()
            ) { (result) in
                switch result {
                    
                case .success(let response):
                    guard let url = URL(string: response.data.attributes.payUrl) else {
                        completion(.error(Model.PaymentError.paymentUrlIsInvalid))
                        return
                    }
                    let atomicSwapPaymentUrl = Model.AtomicSwapPaymentUrl(url: url)
                    completion(.success(atomicSwapPaymentUrl))
                    
                case .failure(let error):
                    completion(.error(error))
                }
            }
        }
    }
}

extension PaymentMethod.FiatPaymentSender: PaymentMethod.PaymentSenderProtocol {
    
    public func sendPayment(
        transaction: TransactionModel,
        completion: @escaping (PaymentMethodPaymentSenderResult) -> Void
        ) {
        
        try? self.sendTransaction(transaction, completion: completion)
    }
}
