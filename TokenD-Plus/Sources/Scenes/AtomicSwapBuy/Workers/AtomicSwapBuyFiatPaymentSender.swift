import Foundation
import TokenDSDK
import TokenDWallet
import RxCocoa

public enum AtomicSwapBuyPaymentSenderResult {
    case success(AtomicSwapBuy.Model.AtomicSwapPaymentType)
    case error(Swift.Error)
}
public protocol AtomicSwapBuyPaymentSenderProtocol {
    func sendPayment(
        quoteAsset: String,
        transaction: TransactionModel,
        completion: @escaping (AtomicSwapBuyPaymentSenderResult) -> Void
    )
}

extension AtomicSwapBuy {
    public typealias PaymentSenderProtocol = AtomicSwapBuyPaymentSenderProtocol
    
    public class FiatPaymentSender {
        
        // MARK: - Private properties
        
        private let api: IntegrationsApiV3
        private let keychainDataProvider: KeychainDataProviderProtocol
        
        
        
        // MARK: -
        
        public init(
            api: IntegrationsApiV3,
            keychainDataProvider: KeychainDataProviderProtocol
            ) {
            
            self.api = api
            self.keychainDataProvider = keychainDataProvider
        }
        
        // MARK: - Private
        
        private func sendTransaction(
            quoteAsset: String,
            transaction: TransactionModel,
            shouldSign: Bool = true,
            completion: @escaping (AtomicSwapBuyPaymentSenderResult) -> Void
            ) throws {
            
            if shouldSign {
                try transaction.addSignature(signer: self.keychainDataProvider.getKeyData())
            }
            self.api.sendAtomicSwapBuyRequest(
                envelope: transaction.getEnvelope().toXdrBase64String()
            ) { [weak self] (result) in
                switch result {
                    
                case .success(let document):
                    guard let resource = document.data else {
                        return
                    }
                    self?.handleResponse(
                        quoteAsset: quoteAsset,
                        resource: resource,
                        completion: completion
                    )
                    
                case .failure(let error):
                    completion(.error(error))
                }
            }
        }
        
        private func handleResponse(
            quoteAsset: String,
            resource: AtomicSwapBuyResource,
            completion: @escaping (AtomicSwapBuyPaymentSenderResult) -> Void) {
            
            if let fiat = resource.fiatDetails {
                guard let url = URL(string: fiat.pay_url) else {
                    completion(.error(AtomicSwapBuy.Event.AtomicSwapBuyAction.AtomicSwapError.paymentUrlIsInvalid))
                    return
                }
                let atomicSwapPaymentUrl = AtomicSwapBuy.Model.AtomicSwapPaymentUrl(url: url)
                completion(.success(.fiat(atomicSwapPaymentUrl)))
            } else if
                let crypto = resource.cryptoDetails,
                let amount = Decimal(string: crypto.amount) {
                
                let atomicSwapInvoice = AtomicSwapBuy.Model.AtomicSwapInvoiceModel(
                    address: crypto.address,
                    asset: quoteAsset,
                    amount: amount
                )
                completion(.success(.crypto(atomicSwapInvoice)))
            }
        }
    }
}

extension AtomicSwapBuy.FiatPaymentSender: AtomicSwapBuy.PaymentSenderProtocol {
    public func sendPayment(
        quoteAsset: String,
        transaction: TransactionModel,
        completion: @escaping (AtomicSwapBuyPaymentSenderResult) -> Void
        ) {
        
        try? self.sendTransaction(
            quoteAsset: quoteAsset,
            transaction: transaction,
            completion: completion
        )
    }
}
