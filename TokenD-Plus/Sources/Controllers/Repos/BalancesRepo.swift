import Foundation
import TokenDSDK
import TokenDWallet
import DLCryptoKit
import RxCocoa
import RxSwift

public class BalancesRepo {
    
    // MARK: - Private properties
    
    private let api: AccountsApiV3
    private let transactionSender: TransactionSender
    private let originalAccountId: String
    private let accountId: AccountID
    private let walletId: String
    private let networkInfoFetcher: NetworkInfoFetcher
    
    private let disposeBag = DisposeBag()
    
    private var shouldInitiateLoad: Bool = true
    
    private let convertedBalancesStates: BehaviorRelay<[ConvertedBalanceStateResource]> = BehaviorRelay(value: [])
    private var loadingStatus: BehaviorRelay<LoadingStatus> = BehaviorRelay<LoadingStatus>(value: .loaded)
    private let errorStatus: PublishRelay<Swift.Error> = PublishRelay()
    private let conversionAsset: String = "UAH"
    
    // MARK: - Public properties
    
    public var convertedBalancesStatesValue: [ConvertedBalanceStateResource] {
        return self.convertedBalancesStates.value
    }
    
    public var loadingStatusValue: LoadingStatus {
        return self.loadingStatus.value
    }
    
    // MARK: -
    
    public init(
        api: AccountsApiV3,
        transactionSender: TransactionSender,
        originalAccountId: String,
        accountId: AccountID,
        walletId: String,
        networkInfoFetcher: NetworkInfoFetcher
        ) {
        
        self.api = api
        self.transactionSender = transactionSender
        self.originalAccountId = originalAccountId
        self.accountId = accountId
        self.walletId = walletId
        self.networkInfoFetcher = networkInfoFetcher
        
        self.observeRepoErrorStatus()
        self.observeTransactionActions()
    }
    
    // MARK: - Private
    
    private enum ReloadConvertedBalancesStatesResult {
        case succeeded(balances: [ConvertedBalanceStateResource])
        case failed(ApiErrors)
    }
    private func reloadConvertedBalancesStates(
        _ completion: ((ReloadConvertedBalancesStatesResult) -> Void)? = nil
        ) {
        
        self.loadingStatus.accept(.loading)
        self.api.requestConvertedBalances(
            accountId: self.originalAccountId,
            convertationAsset: self.conversionAsset,
            include: ["states", "balance", "balance.state", "balance.asset"],
            completion: { [weak self] (result) in
                switch result {
                    
                case .failure(let error):
                    self?.errorStatus.accept(error)
                    
                case .success(let document):
                    guard let collection = document.data,
                        let states = collection.states else {
                        return
                    }
                    self?.convertedBalancesStates.accept(states)
                }
        })
    }
    
    private func observeRepoErrorStatus() {
        self.errorStatus
            .asObservable()
            .subscribe(onNext: { [weak self] (_) in
                self?.shouldInitiateLoad = true
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeTransactionActions() {
        self.transactionSender
            .observeTransactionActions()
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Public
    
    func observeConvertedBalancesStates() -> Observable<[ConvertedBalanceStateResource]> {
        self.reloadConvertedBalancesStates()
        return self.convertedBalancesStates.asObservable()
    }
    
    func observeLoadingStatus() -> Observable<LoadingStatus> {
        return self.loadingStatus.asObservable()
    }
    
    func observeErrorStatus() -> Observable<Swift.Error> {
        return self.errorStatus.asObservable()
    }
    
    func reloadConvertedBalancesStates() {
        self.loadingStatus.accept(.loading)
        self.reloadConvertedBalancesStates { [weak self] (result) in
            self?.loadingStatus.accept(.loaded)
            switch result {
                
            case .failed(let errors):
                self?.errorStatus.accept(errors)
                
            case .succeeded(let states):
                self?.convertedBalancesStates.accept(states)
            }
        }
    }
    
    enum CreateBalanceResult {
        case succeeded
        case failed(Swift.Error)
    }
    func createBalanceForAsset(
        _ asset: Asset,
        completion: @escaping (CreateBalanceResult) -> Void
        ) {
        
        let existing = self.convertedBalancesStatesValue.first(where: { (state) -> Bool in
            return state.balance?.asset?.id == asset.code
        })
        if existing != nil {
            return
        }
        
        self.networkInfoFetcher.fetchNetworkInfo({ [weak self] (result) in
            switch result {
                
            case .failed(let error):
                completion(.failed(error))
                
            case .succeeded(let networkInfo):
                self?.createBalance(
                    asset: asset.code,
                    networkInfo: networkInfo,
                    completion: completion
                )
            }
        })
    }
    
    private func createBalance(
        asset: String,
        networkInfo: NetworkInfoModel,
        completion: @escaping (CreateBalanceResult) -> Void
        ) {
        
        let createBalanceOperation = ManageBalanceOp(
            action: ManageBalanceAction.create,
            destination: self.accountId,
            asset: asset,
            ext: .emptyVersion()
        )
        
        let transactionBuilder: TransactionBuilder = TransactionBuilder(
            networkParams: networkInfo.networkParams,
            sourceAccountId: self.accountId,
            params: networkInfo.getTxBuilderParams(sendDate: Date())
        )
        
        transactionBuilder.add(
            operationBody: .manageBalance(createBalanceOperation),
            operationSourceAccount: self.accountId
        )
        
        do {
            let transaction = try transactionBuilder.buildTransaction()
            
            try self.transactionSender.sendTransaction(
                transaction,
                completion: { [weak self] (result) in
                    switch result {
                        
                    case .succeeded:
                        self?.reloadConvertedBalancesStates({ [weak self] (result) in
                            switch result {
                            case .failed:
                                break
                            case .succeeded(let states):
                                self?.convertedBalancesStates.accept(states)
                            }
                            completion(.succeeded)
                        })
                        
                    case .failed(let error):
                        completion(.failed(error))
                    }
            })
        } catch let error {
            completion(.failed(error))
        }
    }
}

extension BalancesRepo {
    
    public enum LoadingStatus {
        
        case loading
        case loaded
    }
}
