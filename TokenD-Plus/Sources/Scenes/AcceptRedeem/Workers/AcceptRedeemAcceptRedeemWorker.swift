import Foundation
import TokenDSDK
import TokenDWallet

public enum AcceptRedeemAcceptRedeemResult {
    case failure(AcceptRedeem.Model.AcceptRedeemError)
    case success(AcceptRedeem.Model.RedeemModel)
}
public protocol AcceptRedeemAcceptRedeemWorkerProtocol {
    func acceptRedeem(
        completion: @escaping (AcceptRedeemAcceptRedeemResult) -> Void
    )
}

extension AcceptRedeem {
    public typealias AcceptRedeemWorkerProtocol = AcceptRedeemAcceptRedeemWorkerProtocol
    
    public class AcceptRedeemWorker {
        
        // MARK: - Private properties
        
        private let accountsApiV3: AccountsApiV3
        private let networkInfoFetcher: NetworkInfoFetcher
        private let amountFormatter: AmountFormatterProtocol
        private let redeemRequest: String
        
        private let accountIdSize: Int = 32
        private let int32Size: Int = 4
        private let int64Size: Int = 8
        
        // MARK: -
        
        public init(
            accountsApiV3: AccountsApiV3,
            networkInfoFetcher: NetworkInfoFetcher,
            amountFormatter: AmountFormatterProtocol,
            redeemRequest: String
            ) {
            
            self.accountsApiV3 = accountsApiV3
            self.networkInfoFetcher = networkInfoFetcher
            self.amountFormatter = amountFormatter
            self.redeemRequest = redeemRequest
        }
        
        // MARK: - Private
        
        private func fetchNetworkInfo(
            completion: @escaping (AcceptRedeemAcceptRedeemResult) -> Void
            ) {
            
            self.networkInfoFetcher.fetchNetworkInfo { [weak self] (result) in
                switch result {
                    
                case .failed(let error):
                    completion(.failure(.other(error)))
                    
                case .succeeded(let networkInfo):
                    self?.fetchSenderBalanceId(
                        networkInfo: networkInfo,
                        completion: completion
                    )
                }
            }
        }
        
        private func fetchSenderBalanceId(
            networkInfo: NetworkInfoModel,
            completion: @escaping (AcceptRedeemAcceptRedeemResult) -> Void
            ) {
            
            guard let decodedRequestData = Data(base64Encoded: self.redeemRequest) else {
                completion(.failure(.failedToFetchDecodeRedeemRequest))
                return
            }
            
            var requestBytes = decodedRequestData.bytes
            
            let decodedSenderAccountIdBytes = requestBytes.readBytes(n: self.accountIdSize)
            let decodedSenderAccountIdData = Data(
                bytes: decodedSenderAccountIdBytes,
                count: decodedSenderAccountIdBytes.count
            )
            let senderAccountId = Base32Check.encode(
                version: .accountIdEd25519,
                data: decodedSenderAccountIdData
            )
            
            let assetCodeLength = requestBytes
                .readBytes(n: self.int32Size)
                .getValue(type: Int32.self)
            
            let assetCodeBytes = requestBytes.readBytes(n: Int(assetCodeLength))
            guard let assetCode = String(
                data: Data(bytes: assetCodeBytes, count: assetCodeBytes.count),
                encoding: .utf8
                ) else {
                    completion(.failure(.failedToDecodeRedeemAsset))
                    return
            }
            
            self.accountsApiV3.requestAccount(
                accountId: senderAccountId,
                include: ["balances", "balances.asset"],
                pagination: nil,
                completion: { [weak self] (result) in
                    switch result {
                        
                    case .failure(let error):
                        completion(.failure(.other(error)))
                        
                    case .success(let document):
                        guard let account = document.data else {
                            completion(.failure(.failedToFetchSenderAccount))
                            return
                        }
                        guard let balances = account.balances else {
                            completion(.failure(.failedToFindSenderBalance))
                            return
                        }
                        guard let balance = balances.first(where: { (balance) -> Bool in
                            return balance.asset?.id ?? "" == assetCode
                        }), let senderBalanceId = balance.id else {
                            completion(.failure(.failedToFindSenderBalance))
                            return
                        }
                        self?.buildRedeemModel(
                            networkInfo: networkInfo,
                            requestBytes: &requestBytes,
                            asset: assetCode,
                            senderAccountId: senderAccountId,
                            senderBalanceId: senderBalanceId,
                            completion: completion
                        )
                    }
            })
        }
        
        private func buildRedeemModel(
            networkInfo: NetworkInfoModel,
            requestBytes: inout [Int8],
            asset: String,
            senderAccountId: String,
            senderBalanceId: String,
            completion: @escaping (AcceptRedeemAcceptRedeemResult) -> Void
            ) {
            
            let amount = requestBytes
                .readBytes(n: self.int64Size)
                .getValue(type: UInt64.self)
            
            let formattedAmount = self.amountFormatter.format(
                amount: amount,
                precision: networkInfo.precision
            )
            
            let salt = requestBytes
                .readBytes(n: self.int64Size)
                .getValue(type: UInt64.self)
            
            let minTimeBound = requestBytes
                .readBytes(n: self.int64Size)
                .getValue(type: UInt64.self)
            
            let maxTimeBound = requestBytes
                .readBytes(n: self.int64Size)
                .getValue(type: UInt64.self)
            
            let hintBytes: [Int8] = requestBytes.readBytes(n: XDRDataFixed4.length)
            guard let hint = try? SignatureHint(Data(
                bytes: hintBytes,
                count: XDRDataFixed4.length
                )) else {
                return
            }
            let signature = Signature(
                bytes: requestBytes,
                count: requestBytes.count
            )
            
            let acceptRedeemModel = Model.RedeemModel(
                senderAccountId: senderAccountId,
                senderBalanceId: senderBalanceId,
                asset: asset,
                amount: formattedAmount,
                salt: salt,
                minTimeBound: minTimeBound,
                maxTimeBound: maxTimeBound,
                hintWrapped: hint.wrapped,
                signature: signature
            )
            completion(.success(acceptRedeemModel))
        }
    }
}

extension AcceptRedeem.AcceptRedeemWorker: AcceptRedeem.AcceptRedeemWorkerProtocol {
    
    public func acceptRedeem(
        completion: @escaping (AcceptRedeemAcceptRedeemResult) -> Void
        ) {
        
        self.fetchNetworkInfo(completion: completion)
    }
}

