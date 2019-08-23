import Foundation
import TokenDSDK
import TokenDWallet

enum SendPaymentAmountCreateRedeemRequest {
    case failure(SendPaymentAmount.Event.RedeemAction.RedeemError)
    case success(SendPaymentAmount.Model.ShowRedeemModel)
}
protocol SendPaymentAmountCreateRedeemRequestWorkerProtocol {
    func createRedeemRequest(
        assetCode: String,
        assetName: String,
        amount: Decimal,
        completion: @escaping (SendPaymentAmountCreateRedeemRequest) -> Void
    )
}

extension SendPaymentAmount {
    typealias CreateRedeemRequestWorkerProtocol = SendPaymentAmountCreateRedeemRequestWorkerProtocol
    
    class CreateRedeemRequestWorker {
        
        // MARK: - Private properties
        
        private let balancesRepo: BalancesRepo
        private let networkRepo: NetworkInfoRepo
        private let keychainManager: KeychainManagerProtocol
        private let amountConverter: AmountConverterProtocol
        private let originalAccountId: String
        
        // MARK: -
        
        init(
            balancesRepo: BalancesRepo,
            networkRepo: NetworkInfoRepo,
            keychainManager: KeychainManagerProtocol,
            amountConverter: AmountConverterProtocol,
            originalAccountId: String
            ) {
            
            self.balancesRepo = balancesRepo
            self.networkRepo = networkRepo
            self.keychainManager = keychainManager
            self.amountConverter = amountConverter
            self.originalAccountId = originalAccountId
        }
        
        // MARK: - Private
        
        private func requestNetworkInfo(
            assetCode: String,
            assetName: String,
            amount: Decimal,
            completion: @escaping (SendPaymentAmountCreateRedeemRequest) -> Void
            ) {
            
            self.networkRepo.fetchNetworkInfo { [weak self] (result) in
                switch result {
                    
                case .failed(let error):
                    completion(.failure(.other(error)))
                    
                case .succeeded(let networkInfo):
                    self?.requestAsset(
                        assetCode: assetCode,
                        assetName: assetName,
                        amount: amount,
                        networkInfo: networkInfo,
                        completion: completion
                    )
                }
            }
        }
        
        private func requestAsset(
            assetCode: String,
            assetName: String,
            amount: Decimal,
            networkInfo: NetworkInfoModel,
            completion: @escaping (SendPaymentAmountCreateRedeemRequest) -> Void
            ) {
            
            guard
                let state = self.balancesRepo.convertedBalancesStatesValue.first(where: { (state) -> Bool in
                return state.balance?.asset?.id == assetCode
            }),
                let assetOwner = state.balance?.asset?.owner?.id,
                let balanceId = state.balance?.id else {
                    completion(.failure(.noBalance))
                    return
            }
            
            self.buildTransaction(
                assetCode: assetCode,
                assetName: assetName,
                amount: amount,
                networkInfo: networkInfo,
                ownerAccountId: assetOwner,
                balanceId: balanceId,
                completion: completion
            )
        }
        
        private func buildTransaction(
            assetCode: String,
            assetName: String,
            amount: Decimal,
            networkInfo: NetworkInfoModel,
            ownerAccountId: String,
            balanceId: String,
            completion: @escaping (SendPaymentAmountCreateRedeemRequest) -> Void
            ) {
            
            guard let sourceAccountID = AccountID(
                base32EncodedString: self.originalAccountId,
                expectedVersion: .accountIdEd25519
                ) else {
                    completion(.failure(.failedToDecodeAccountId(.senderAccountId)))
                    return
            }
            
            guard let sourceBalanceID = BalanceID(
                base32EncodedString: balanceId,
                expectedVersion: .balanceIdEd25519
                ) else {
                     completion(.failure(.failedToDecodeBalanceId(.senderBalanceId)))
                    return
            }
            
            guard let destinationAccountID = AccountID(
                base32EncodedString: ownerAccountId,
                expectedVersion: .accountIdEd25519
                ) else {
                    completion(.failure(.failedToDecodeAccountId(.recipientAccountId)))
                    return
            }
            
            let sourceFee = Fee(fixed: 0, percent: 0, ext: .emptyVersion())
            let destinationFee = Fee(fixed: 0, percent: 0, ext: .emptyVersion())
            let feeData = PaymentFeeData(
                sourceFee: sourceFee,
                destinationFee: destinationFee,
                sourcePaysForDest: false,
                ext: .emptyVersion()
            )
            
            let convertedAmount = self.amountConverter.convertDecimalToUInt64(
                    value: amount,
                    precision: networkInfo.precision
            )
            
            var generator = SystemRandomNumberGenerator()
            let mask: UInt64 = 0xffffffff
            let salt = generator.next() & mask
            
            let operation = PaymentOp(
                sourceBalanceID: sourceBalanceID,
                destination: .account(destinationAccountID),
                amount: Uint64(convertedAmount),
                feeData: feeData,
                subject: "",
                reference: salt.description,
                ext: .emptyVersion()
            )
            let transactionBuilder = TransactionBuilder(
                networkParams: networkInfo.networkParams,
                sourceAccountId: sourceAccountID,
                params: networkInfo.getTxBuilderParams(
                    memo: nil,
                    salt: Uint64(salt),
                    sendDate: Date()
                )
            )
            transactionBuilder.add(operationBody: .payment(operation))
            
            guard let transaction = try? transactionBuilder.buildTransaction() else {
                return
            }
            self.signTransaction(
                assetCode: assetCode,
                assetName: assetName,
                amount: amount,
                convertedAmount: Int64(convertedAmount),
                transaction: transaction,
                completion: completion
            )
        }
        
        private func signTransaction(
            assetCode: String,
            assetName: String,
            amount: Decimal,
            convertedAmount: Int64,
            transaction: TransactionModel,
            completion: @escaping (SendPaymentAmountCreateRedeemRequest) -> Void
            ) {
            
            guard let account = self.keychainManager.getMainAccount(),
                let signer = self.keychainManager.getKeyData(account: account) else {
                    completion(.failure(.failedToSignTransaction))
                    return
            }
            guard let _ = try? transaction.addSignature(signer: signer) else {
                completion(.failure(.failedToSignTransaction))
                return
            }
            self.createRedeemRequest(
                assetCode: assetCode,
                assetName: assetName,
                amount: amount,
                convertedAmount: convertedAmount,
                transaction: transaction,
                completion: completion
            )
        }
        
        private func createRedeemRequest(
            assetCode: String,
            assetName: String,
            amount: Decimal,
            convertedAmount: Int64,
            transaction: TransactionModel,
            completion: @escaping (SendPaymentAmountCreateRedeemRequest) -> Void
            ) {
            
            var redeemBytes: [Int8] = []
            guard let sourceAccountIdData = try? Base32Check.decode(encoded: self.originalAccountId) else {
                completion(.failure(.failedToDecodeAccountId(.senderAccountId)))
                return
            }
            redeemBytes.append(contentsOf: sourceAccountIdData.data.bytes)
            redeemBytes.append(contentsOf: Int32(assetCode.count).bytes)
            
            guard let assetData = assetCode.data(using: .utf8) else {
                completion(.failure(.failedToGetAssetData))
                return
            }
            redeemBytes.append(contentsOf: assetData.bytes)
            redeemBytes.append(contentsOf: convertedAmount.bytes)
            redeemBytes.append(contentsOf: transaction.salt.bytes)
            redeemBytes.append(contentsOf: transaction.timeBounds.minTime.bytes)
            redeemBytes.append(contentsOf: transaction.timeBounds.maxTime.bytes)
            
            guard let signature = transaction.signatures.first else {
                completion(.failure(.failedToGetTransactionSignature))
                return
            }
            redeemBytes.append(contentsOf: signature.hint.wrapped.bytes)
            redeemBytes.append(contentsOf: signature.signature.bytes)
            
            let redeemRequestData = Data(bytes: redeemBytes, count: redeemBytes.count)
            
            let redeemToShow = Model.ShowRedeemModel(
                redeemRequest: redeemRequestData.base64EncodedString(),
                amount: amount,
                assetName: assetName
            )
            completion(.success(redeemToShow))
        }
    }
}

extension SendPaymentAmount.CreateRedeemRequestWorker: SendPaymentAmount.CreateRedeemRequestWorkerProtocol {
    
    func createRedeemRequest(
        assetCode: String,
        assetName: String,
        amount: Decimal,
        completion: @escaping (SendPaymentAmountCreateRedeemRequest) -> Void
        ) {
        
        self.requestNetworkInfo(
            assetCode: assetCode,
            assetName: assetName,
            amount: amount,
            completion: completion
        )
    }
}
