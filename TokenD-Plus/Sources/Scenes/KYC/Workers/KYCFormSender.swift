import Foundation
import TokenDSDK
import TokenDWallet

public enum KYCFormSenderResult {
    case success
    case error(KYC.Model.KYCError)
}
public protocol KYCFormSenderProtocol {
    func submitKYCRequest(
        name: String,
        surname: String,
        completion: @escaping(KYCFormSenderResult) -> Void
    )
}

extension KYC {
    
    public class KYCFormSender {
        
        // MARK: - Private properties
        
        private let accountsApi: AccountsApi
        private let accountsApiV3: AccountsApiV3
        private let keyValueApi: KeyValuesApiV3
        private let transactionSender: TransactionSender
        private let networkFetcher: NetworkInfoFetcher
        private let originalAccountId: String
        
        // MARK: -
        
        init(
            accountsApi: AccountsApi,
            accountsApiV3: AccountsApiV3,
            keyValueApi: KeyValuesApiV3,
            transactionSender: TransactionSender,
            networkFetcher: NetworkInfoFetcher,
            originalAccountId: String
            ) {
            
            self.accountsApi = accountsApi
            self.accountsApiV3 = accountsApiV3
            self.keyValueApi = keyValueApi
            self.transactionSender = transactionSender
            self.networkFetcher = networkFetcher
            self.originalAccountId = originalAccountId
        }
        
        // MARK: - Private
        
        private func fetchNetworkInfo(
            name: String,
            surname: String,
            completion: @escaping(KYCFormSenderResult) -> Void
            ) {
            
            self.networkFetcher.fetchNetworkInfo { [weak self] (result) in
                switch result {
                    
                case .failed(let error):
                    completion(.error(.other(error)))
                    
                case .succeeded(let networkInfo):
                    self?.fetchRole(
                        name: name,
                        surname: surname,
                        networkInfo: networkInfo,
                        completion: completion
                    )
                }
            }
        }
        
        private func fetchRole(
            name: String,
            surname: String,
            networkInfo: NetworkInfoModel,
            completion: @escaping(KYCFormSenderResult) -> Void
            ) {
            
            let pagination = RequestPagination(.single(index: 0, limit: 100, order: .descending))
            self.keyValueApi.requestKeyValueEntries(
                pagination: pagination,
                completion: { [weak self] (result) in
                    switch result {
                        
                    case .failure(let error):
                        completion(.error(.other(error)))
                        
                    case .success(let document):
                        guard
                            let keyValues = document.data,
                            let roleEntry = keyValues.first(where: { (keyValue) -> Bool in
                                return keyValue.id == KeyValueEntries.accountRoleGeneral
                            }),
                            let role32 = roleEntry.value?.u32
                            else {
                                completion(.error(.failedToBuildTransaction))
                                return
                        }
                        
                        self?.sendBlob(
                            name: name,
                            surname: surname,
                            networkInfo: networkInfo,
                            role: UInt64(role32),
                            completion: completion
                        )
                        
                    }
            })
        }
        
        private func sendBlob(
            name: String,
            surname: String,
            networkInfo: NetworkInfoModel,
            role: UInt64,
            completion: @escaping(KYCFormSenderResult) -> Void
            ) {
            
            let kycForm = BlobResponse.BlobContent.KYCFormResponse(
                firstName: name,
                lastName: surname,
                documents: nil
            )
            
            guard let kycFormJSONData = try? JSONCoders.snakeCaseEncoder.encode(kycForm),
                let kycFormJSONString = String(data: kycFormJSONData, encoding: .utf8) else {
                    completion(.error(.failedToFormBlob))
                    return
            }
            
            let attributes: JSON = [
                "value": kycFormJSONString
            ]
            
            let blob = UploadBlobModel(
                type: BlobType.kycForm,
                attributes: attributes
            )
            
            self.accountsApi.uploadBlob(
                accountId: self.originalAccountId,
                blob: blob,
                completion: { [weak self] (result) in
                    switch result {
                        
                    case .failure(let error):
                        completion(.error(.other(error)))
                        
                    case .success(let blobResponse):
                        self?.buildChangeRoleRequest(
                            blobResponse: blobResponse,
                            role: role,
                            networkInfo: networkInfo,
                            completion: completion
                        )
                    }
                }
            )
        }
        
        private func buildChangeRoleRequest(
            blobResponse: UploadBlobResponse,
            role: UInt64,
            networkInfo: NetworkInfoModel,
            completion: @escaping(KYCFormSenderResult) -> Void
            ) {
            
            guard let destinationAccountID = AccountID(
                base32EncodedString: self.originalAccountId,
                expectedVersion: .accountIdEd25519
                ) else {
                    completion(.error(.failedToBuildTransaction))
                    return
            }
            let creatorDetails = "{\"blob_id\": \"\(blobResponse.id)\"}"
            
            let changeOpReviewableRequest = CreateChangeRoleRequestOp(
                requestID: 0,
                destinationAccount: destinationAccountID,
                accountRoleToSet: role,
                creatorDetails: creatorDetails,
                allTasks: nil,
                ext: .emptyVersion()
            )
            
            let transactionBuilder = TransactionBuilder(
                networkParams: networkInfo.networkParams,
                sourceAccountId: destinationAccountID,
                params: networkInfo.getTxBuilderParams(sendDate: Date())
            )
            transactionBuilder.add(operationBody: .createChangeRoleRequest(changeOpReviewableRequest))
            
            guard let transaction = try? transactionBuilder.buildTransaction() else {
                completion(.error(.failedToBuildTransaction))
                return
            }
            
            self.sendTransaction(
                transaction: transaction,
                completion: completion
            )
        }
        
        private func sendTransaction(
            transaction: TransactionModel,
            completion: @escaping(KYCFormSenderResult) -> Void
            ) {
            
            try? self.transactionSender.sendTransaction(
                transaction,
                completion: { (result) in
                    switch result {
                        
                    case .failed(let error):
                        completion(.error(.other(error)))
                        
                    case .succeeded:
                        completion(.success)
                    }
            })
        }
    }
}

extension KYC.KYCFormSender: KYCFormSenderProtocol {
    
    public func submitKYCRequest(
        name: String,
        surname: String,
        completion: @escaping(KYCFormSenderResult) -> Void
        ) {
        
        self.fetchNetworkInfo(
            name: name,
            surname: surname,
            completion: completion
        )
    }
}
