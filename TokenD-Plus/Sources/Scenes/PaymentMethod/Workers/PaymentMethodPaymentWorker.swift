import Foundation
import TokenDSDK
import TokenDWallet

public enum PaymentMethodPaymentResult {
    case failure(PaymentMethod.Model.PaymentError)
    case success(PaymentMethod.Model.AtomicSwapPaymentUrl)
}
public protocol PaymentMethodPaymentWorkerProtocol {
    func performPayment(
        quoteAsset: String,
        quoteAmount: Decimal,
        completion: @escaping(PaymentMethodPaymentResult) -> Void
    )
}

extension PaymentMethod {
    public typealias PaymentWorkerProtocol = PaymentMethodPaymentWorkerProtocol
    
    public class AtomicSwapPaymentWorker {
        
        // MARK: - Private properties
        
        private let accountsApi: AccountsApiV3
        private let requestsApi: RequestsApiV3
        private let networkFetcher: NetworkInfoFetcher
        private let transactionSender: TransactionSender
        private let amountConverter: AmountConverterProtocol
        private let paymentSender: PaymentSenderProtocol
        
        private let askModel: Model.AskModel
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
            askModel: Model.AskModel,
            originalAccountId: String
            ) {
            
            self.accountsApi = accountsApi
            self.requestsApi = requestsApi
            self.networkFetcher = networkFetcher
            self.transactionSender = transactionSender
            self.amountConverter = amountConverter
            self.paymentSender = fiatPaymentSender
            self.askModel = askModel
            self.originalAccountId = originalAccountId
        }
        
        // MARK: - Private
        
        private func fetchNetworkInfo(
            quoteAsset: String,
            quoteAmount: Decimal,
            completion: @escaping(PaymentMethodPaymentResult) -> Void
            ) {
            
            self.networkFetcher.fetchNetworkInfo { [weak self] (result) in
                switch result {
                    
                case .failed(let error):
                    completion(.failure(.other(error)))
                    
                case .succeeded(let networkInfo):
                    self?.buildBidTransaction(
                        networkInfo: networkInfo,
                        quoteAmount: quoteAmount,
                        quoteAsset: quoteAsset,
                        completion: completion
                    )
                }
            }
        }
        
        private func buildBidTransaction(
            networkInfo: NetworkInfoModel,
            quoteAmount: Decimal,
            quoteAsset: String,
            completion: @escaping(PaymentMethodPaymentResult) -> Void
            ) {
            
            guard let askID = UInt64(self.askModel.ask.id) else {
                completion(.failure(.askIsNotFound))
                return
            }
            let baseAmount = self.amountConverter.convertDecimalToUInt64(
                value: self.askModel.amount,
                precision: networkInfo.precision
            )
            
            let request = CreateAtomicSwapBidRequest(
                askID: askID,
                baseAmount: baseAmount,
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
                completion: { result in
                    switch result {
                        
                    case .error(let error):
                        completion(.failure(.other(error)))
                        
                    case .success(let atomicSwapUrl):
                        completion(.success(atomicSwapUrl))
                    }
            })
        }
        
//        private func sendCreatBidRequestTransaction(
//            transactionModel: TransactionModel,
//            networkInfo: NetworkInfoModel,
//            quoteAmount: Decimal,
//            completion: @escaping(PaymentMethodPaymentResult) -> Void
//            ) {
//
//            guard let _ = try? self.transactionSender.sendTransaction(
//                transactionModel,
//                completion: { [weak self] (result) in
//                    switch result {
//
//                    case .failed(let error):
//                        completion(.failure(.other(error)))
//
//                    case .succeeded:
//                        self?.fetchCreateBidRequest(
//                            networkInfo: networkInfo,
//                            quoteAmount: quoteAmount,
//                            completion: completion
//                        )
//                    }
//            }) else {
//                completion(.failure(.failedToSendTransaction))
//                return
//            }
//        }
//
//        private func fetchCreateBidRequest(
//            networkInfo: NetworkInfoModel,
//            quoteAmount: Decimal,
//            completion: @escaping(PaymentMethodPaymentResult) -> Void
//            ) {
//
//            let filter = RequestsFiltersV3.with(.requestor(self.originalAccountId))
//            let requestPagination = RequestPagination(
//                .single(index: 0, limit: 3, order: .descending)
//            )
//
//            self.requestsApi.requestRequests(
//                filters: filter,
//                include: [self.requestDetails],
//                pagination: requestPagination,
//                onRequestBuilt: nil,
//                completion: { [weak self] (result) in
//                    switch result {
//
//                    case .failure(let error):
//                        completion(.failure(.other(error)))
//
//                    case .success(let document):
//                        guard let requests = document.data,
//                            let firstRequest = requests.first,
//                            let firstRequestId = firstRequest.id else {
//                                completion(.failure(.failedToFetchCreateBidRequest))
//                                return
//                        }
//
//                        self?.fetchAccountsRequest(
//                            requestId: firstRequestId,
//                            networkInfo: networkInfo,
//                            quoteAmount: quoteAmount,
//                            completion: completion
//                        )
//                    }
//                })
//        }
//
//        private func fetchAccountsRequest(
//            requestId: String,
//            networkInfo: NetworkInfoModel,
//            quoteAmount: Decimal,
//            completion: @escaping(PaymentMethodPaymentResult) -> Void
//            ) {
//
//            let requestPagination = RequestPagination(
//                .single(index: 0, limit: 3, order: .descending)
//            )
//            self.accountsApi.requestAccountRequest(
//                accountId: self.originalAccountId,
//                requestId: requestId,
//                pagination: requestPagination,
//                completion: { [weak self] (result) in
//                    switch result {
//
//                    case .failure(let error):
//                        completion(.failure(.other(error)))
//
//                    case .success(let document):
//                        guard let request = document.data else {
//                            completion(.failure(.createBidRequestIsNotFound))
//                            return
//                        }
//                        self?.handleAccountsRequest(
//                            request: request,
//                            requestId: requestId,
//                            networkInfo: networkInfo,
//                            quoteAmount: quoteAmount,
//                            completion: completion
//                        )
//                    }
//                }
//            )
//        }
//
//        private func handleAccountsRequest(
//            request: TokenDSDK.ReviewableRequestResource,
//            requestId: String,
//            networkInfo: NetworkInfoModel,
//            quoteAmount: Decimal,
//            completion: @escaping(PaymentMethodPaymentResult) -> Void
//            ) {
//
//            guard
//            request.stateI != ReviewableRequestState.permanentlyRejected.rawValue &&
//                request.stateI != ReviewableRequestState.rejected.rawValue else {
//                    completion(.failure(.paymentIsRejected))
//                    return
//            }
//
//            guard let externalDetails = request.cryptoDetails else {
//                    completion(.failure(.externalDetailsAreNotFound))
//                    return
//            }
//
//            guard let firstInvoice = externalDetails.data.first else {
//                self.dispatchQueue.asyncAfter(
//                    deadline: .now() + .milliseconds(1500),
//                    execute: { [weak self] in
//                        self?.fetchAccountsRequest(
//                            requestId: requestId,
//                            networkInfo: networkInfo,
//                            quoteAmount: quoteAmount,
//                            completion: completion
//                        )
//                })
//                return
//            }
//
//            let decimalAmount = self.amountConverter.convertUInt64ToDecimal(
//                value: firstInvoice.amount,
//                precision: networkInfo.precision
//            )
//
////            let atomicSwapInvoice = Model.AtomicSwapPaymentUrl(
////                address: firstInvoice.address,
////                asset: firstInvoice.assetCode,
////                amount: decimalAmount
////            )
////            completion(.success(atomicSwapInvoice))
//        }
    }
}

extension PaymentMethod.AtomicSwapPaymentWorker: PaymentMethod.PaymentWorkerProtocol {
    
    public func performPayment(
        quoteAsset: String,
        quoteAmount: Decimal,
        completion: @escaping(PaymentMethodPaymentResult) -> Void
        ) {
        
        self.fetchNetworkInfo(
            quoteAsset: quoteAsset,
            quoteAmount: quoteAmount,
            completion: completion
        )
    }
}

extension TokenDSDK.ReviewableRequestResource {
    
    var cryptoDetails: CryptoDetails? {
        let details = self.externalDetails as Any
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: details, options: []) else {
            return nil
        }
        
        guard let externalDetails = try? JSONDecoder().decode(
            CryptoDetails.self,
            from: jsonData
            ) else { return nil }
        
        return externalDetails
    }
    
    var fiatDetails: FiatDetails? {
        let details = self.externalDetails as Any
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: details, options: []) else {
            return nil
        }
        
        guard let externalDetails = try? JSONDecoder().decode(
            FiatDetails.self,
            from: jsonData
            ) else { return nil }
        
        return externalDetails
    }
    
    
    public struct CryptoDetails: Decodable {
        public let data: [AtomicSwapInvoice]
        
        public struct AtomicSwapInvoice: Decodable {
            let address: String
            let assetCode: String
            let amount: UInt64
        }
    }
    
    public struct FiatDetails: Decodable {
        let data: [PaymentDetails]
        
        public struct PaymentDetails: Decodable {
            let stripeInvoice: StripeInvoice
            
            public struct StripeInvoice: Decodable {
                let clientSecret: String
                let id: String
            }
        }
    }
}
