import Foundation
import TokenDSDK
import TokenDWallet

public enum AtomicSwapBuyAtomicSwapPaymentResult {
    case failure(AtomicSwapBuy.Event.AtomicSwapBuyAction.AtomicSwapError)
    case success(AtomicSwapBuy.Model.AtomicSwapPaymentType)
}
public protocol AtomicSwapBuyAtomicSwapPaymentWorkerProtocol {
    func performPayment(
        baseAmount: Decimal,
        quoteAsset: String,
        completion: @escaping(AtomicSwapBuyAtomicSwapPaymentResult) -> Void
    )
}

extension AtomicSwapBuy {
    public typealias AtomicSwapPaymentWorkerProtocol = AtomicSwapBuyAtomicSwapPaymentWorkerProtocol
    
    public class AtomicSwapPaymentWorker {
        
        // MARK: - Private properties
        
        private let accountsApi: AccountsApiV3
        private let requestsApi: RequestsApiV3
        private let networkFetcher: NetworkInfoFetcher
        private let transactionSender: TransactionSender
        private let amountConverter: AmountConverterProtocol
        private let paymentSender: PaymentSenderProtocol
        
        private let ask: Model.Ask
        private let originalAccountId: String
        
        private let dispatchQueue: DispatchQueue = DispatchQueue(
            label: "payment_queue",
            qos: .userInteractive
        )
        private let requestDetails: String = "request_details"
        
        // MARK: -
        
        init(
            accountsApi: AccountsApiV3,
            requestsApi: RequestsApiV3,
            networkFetcher: NetworkInfoFetcher,
            transactionSender: TransactionSender,
            amountConverter: AmountConverterProtocol,
            fiatPaymentSender: PaymentSenderProtocol,
            ask: Model.Ask,
            originalAccountId: String
            ) {
            
            self.accountsApi = accountsApi
            self.requestsApi = requestsApi
            self.networkFetcher = networkFetcher
            self.transactionSender = transactionSender
            self.amountConverter = amountConverter
            self.paymentSender = fiatPaymentSender
            self.ask = ask
            self.originalAccountId = originalAccountId
        }
        
        // MARK: - Private
        
        private func fetchNetworkInfo(
            baseAmount: Decimal,
            quoteAsset: String,
            completion: @escaping(AtomicSwapBuyAtomicSwapPaymentResult) -> Void
            ) {
            
            self.networkFetcher.fetchNetworkInfo { [weak self] (result) in
                switch result {
                    
                case .failed(let error):
                    completion(.failure(.other(error)))
                    
                case .succeeded(let networkInfo):
                    self?.buildBidTransaction(
                        networkInfo: networkInfo,
                        baseAmount: baseAmount,
                        quoteAsset: quoteAsset,
                        completion: completion
                    )
                }
            }
        }
        
        private func buildBidTransaction(
            networkInfo: NetworkInfoModel,
            baseAmount: Decimal,
            quoteAsset: String,
            completion: @escaping(AtomicSwapBuyAtomicSwapPaymentResult) -> Void
            ) {
            
            guard let askID = UInt64(self.ask.id) else {
                completion(.failure(.askIsNotFound))
                return
            }
            let baseAmountValue = self.amountConverter.convertDecimalToUInt64(
                value: baseAmount,
                precision: networkInfo.precision
            )
            
            let request = CreateAtomicSwapBidRequest(
                askID: askID,
                baseAmount: baseAmountValue,
                quoteAsset: quoteAsset,
                creatorDetails: "",
                ext: .emptyVersion()
            )
            
            guard let sourceAccountID = AccountID(
                base32EncodedString: self.originalAccountId,
                expectedVersion: .accountIdEd25519
                ) else {
                    completion(.failure(.failedToDecodeSourceAccountId))
                    return
            }
            
            let operation = CreateAtomicSwapBidRequestOp(
                request: request,
                ext: .emptyVersion()
            )
            
            let transactionBuilder = TransactionBuilder(
                networkParams: networkInfo.networkParams,
                sourceAccountId: sourceAccountID,
                params: networkInfo.getTxBuilderParams(sendDate: Date())
            )
            transactionBuilder.add(
                operationBody: .createAtomicSwapBidRequest(operation)
            )
            
            guard let transaction = try? transactionBuilder.buildTransaction() else {
                completion(.failure(.failedToBuildTransaction))
                return
            }
            
            self.paymentSender.sendPayment(
                quoteAsset: quoteAsset,
                transaction: transaction,
                completion: { result in
                    switch result {
                        
                    case .error(let error):
                        completion(.failure(.other(error)))
                        
                    case .success(let paymentType):
                        completion(.success(paymentType))
                    }
            })
        }
    }
}

extension AtomicSwapBuy.AtomicSwapPaymentWorker: AtomicSwapBuy.AtomicSwapPaymentWorkerProtocol {
    
    public func performPayment(
        baseAmount: Decimal,
        quoteAsset: String,
        completion: @escaping(AtomicSwapBuyAtomicSwapPaymentResult) -> Void
        ) {
        
        self.fetchNetworkInfo(
            baseAmount: baseAmount,
            quoteAsset: quoteAsset,
            completion: completion
        )
    }
}
