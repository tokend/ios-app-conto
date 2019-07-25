import Foundation
import TokenDSDK
import TokenDWallet
import DLCryptoKit
import RxCocoa
import RxSwift

extension ConfirmationScene {
    
    class AcceptRedeemConfirmationSectionsProvider {
        
        private struct DestinationAddress: Encodable {
            let address: String
        }
        
        // MARK: - Private properties
        
        private let redeemModel: Model.RedeemModel
        private let generalApi: GeneralApi
        private let balancesRepo: BalancesRepo
        private let transactionSender: TransactionSender
        private let networkInfoFetcher: NetworkInfoFetcher
        private let userDataProvider: UserDataProviderProtocol
        private let amountFormatter: AmountFormatterProtocol
        private let percentFormatter: PercentFormatterProtocol
        private let amountConverter: AmountConverterProtocol
        private let originalAccountId: String
        private let sectionsRelay: BehaviorRelay<[ConfirmationScene.Model.SectionModel]> = BehaviorRelay(value: [])
        
        private var requestorEmail: String? {
            didSet {
                self.loadConfirmationSections()
            }
        }
        
        // MARK: -
        
        init(
            redeemModel: Model.RedeemModel,
            generalApi: GeneralApi,
            balancesRepo: BalancesRepo,
            transactionSender: TransactionSender,
            networkInfoFetcher: NetworkInfoFetcher,
            amountFormatter: AmountFormatterProtocol,
            userDataProvider: UserDataProviderProtocol,
            amountConverter: AmountConverterProtocol,
            percentFormatter: PercentFormatterProtocol,
            originalAccountId: String
            ) {
            
            self.redeemModel = redeemModel
            self.generalApi = generalApi
            self.balancesRepo = balancesRepo
            self.transactionSender = transactionSender
            self.networkInfoFetcher = networkInfoFetcher
            self.userDataProvider = userDataProvider
            self.amountFormatter = amountFormatter
            self.amountConverter = amountConverter
            self.percentFormatter = percentFormatter
            self.originalAccountId = originalAccountId
            
            self.fetchRequestor()
        }
        
        // MARK: - Private
        
        private func fetchRequestor() {
            self.generalApi.requestIdentities(
                filter: .accountId(self.redeemModel.senderAccountId),
                completion: { [weak self] (result) in
                    switch result {
                    case .failed:
                        self?.requestorEmail = Localized(.undefined)
                        
                    case .succeeded(let identities):
                        if let identity = identities.first {
                            self?.requestorEmail = identity.attributes.email
                        }
                    }
            })
        }
        
        private func confirmationSendPayment(
            networkInfo: NetworkInfoModel,
            completion: @escaping (ConfirmationResult) -> Void
            ) {
            
            let sourceFee = self.emptyFee(networkInfo: networkInfo)
            let destinationFee = self.emptyFee(networkInfo: networkInfo)
            
            let feeData = PaymentFeeData(
                sourceFee: sourceFee,
                destinationFee: destinationFee,
                sourcePaysForDest: false,
                ext: .emptyVersion()
            )
            
            guard let sourceAccountID = AccountID(
                base32EncodedString: self.redeemModel.senderAccountId,
                expectedVersion: .accountIdEd25519
                ) else {
                    completion(.failed(.failedToDecodeAccountId(.senderAccountId)))
                    return
            }
            
            guard let sourceBalanceID = BalanceID(
                base32EncodedString: self.redeemModel.senderBalanceId,
                expectedVersion: .balanceIdEd25519
                ) else {
                    completion(.failed(.failedToDecodeBalanceId(.senderBalanceId)))
                    return
            }
            
            guard let destinationAccountID = AccountID(
                base32EncodedString: self.originalAccountId,
                expectedVersion: .accountIdEd25519
                ) else {
                    completion(.failed(.failedToDecodeAccountId(.recipientAccountId)))
                    return
            }
            
            let operation = PaymentOp(
                sourceBalanceID: sourceBalanceID,
                destination: .account(destinationAccountID),
                amount: self.redeemModel.precisedAmount,
                feeData: feeData,
                subject: "",
                reference: "\(self.redeemModel.salt)",
                ext: .emptyVersion()
            )
            
            let transactionBuilderParams = TransactionBuilderParams(
                memo: nil,
                timeBounds: TimeBounds(
                    minTime: self.redeemModel.minTimeBound,
                    maxTime: self.redeemModel.maxTimeBound
                ),
                salt: self.redeemModel.salt
            )
            let transactionBuilder: TransactionBuilder = TransactionBuilder(
                networkParams: networkInfo.networkParams,
                sourceAccountId: sourceAccountID,
                params: transactionBuilderParams
            )
            
            transactionBuilder.add(
                operationBody: .payment(operation)
            )
            do {
                let transaction = try transactionBuilder.buildTransaction()
                var hint = SignatureHint()
                hint.wrapped = self.redeemModel.hintWrapped
                let decoratedSigntaure = DecoratedSignature(
                    hint: hint,
                    signature: self.redeemModel.signature
                )
                transaction.addSignature(signature: decoratedSigntaure)
                
                try self.transactionSender.sendTransaction(
                    transaction,
                    shouldSign: false,
                    completion: { (result) in
                        switch result {
                        case .succeeded:
                            self.balancesRepo.reloadBalancesDetails()
                            completion(.succeeded)
                        case .failed(let error):
                            completion(.failed(.sendTransactionError(error)))
                        }
                })
            } catch let error {
                completion(.failed(.sendTransactionError(error)))
            }
        }
        
        private func emptyFee(networkInfo: NetworkInfoModel) -> Fee {
            let fixedFee = self.amountConverter.convertDecimalToUInt64(
                value: 0,
                precision: networkInfo.precision
            )
            
            let percent = self.amountConverter.convertDecimalToUInt64(
                value: 0,
                precision: networkInfo.precision
            )
            
            let destinationFee = Fee(
                fixed: fixedFee,
                percent: percent,
                ext: .emptyVersion()
            )
            return destinationFee
        }
    }
}

extension ConfirmationScene.AcceptRedeemConfirmationSectionsProvider: ConfirmationScene.SectionsProvider {
    func observeConfirmationSections() -> Observable<[ConfirmationScene.Model.SectionModel]> {
        return self.sectionsRelay.asObservable()
    }
    
    func loadConfirmationSections() {
        var sections: [ConfirmationScene.Model.SectionModel] = []
        
        let email = self.requestorEmail ?? Localized(.loading)
        let requestorCell = ConfirmationScene.Model.CellModel(
            hint: Localized(.requestor),
            cellType: .text(value: email),
            identifier: .recipient
        )
        let requestorSection = ConfirmationScene.Model.SectionModel(
            title: "",
            cells: [requestorCell]
        )
        sections.append(requestorSection)
        
        let toRedeemAmountCellText = self.amountFormatter.assetAmountToString(
            self.redeemModel.inputAmount
            ) + " " + self.redeemModel.asset
        
        let toRedeemAmountCell = ConfirmationScene.Model.CellModel(
            hint: Localized(.amount),
            cellType: .text(value: toRedeemAmountCellText),
            identifier: .amount
        )
        
        let toRedeemSection = ConfirmationScene.Model.SectionModel(
            title: Localized(.to_redeem),
            cells: [toRedeemAmountCell]
        )
        sections.append(toRedeemSection)
        self.sectionsRelay.accept(sections)
    }
    
    func handleTextEdit(
        identifier: ConfirmationScene.CellIdentifier,
        value: String?
        ) {
        
    }
    
    func handleBoolSwitch(
        identifier: ConfirmationScene.CellIdentifier,
        value: Bool
        ) {
        
    }
    
    func handleConfirmAction(completion: @escaping (_ result: ConfirmationResult) -> Void) {
        self.networkInfoFetcher.fetchNetworkInfo { [weak self] (result) in
            switch result {
                
            case .failed(let error):
                completion(.failed(.networkInfoError(error)))
                
            case .succeeded(let networkInfo):
                self?.confirmationSendPayment(
                    networkInfo: networkInfo,
                    completion: completion
                )
            }
        }
    }
}
