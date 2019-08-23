import Foundation
import RxCocoa
import RxSwift

protocol BalancePickerBalancesFetcherProtocol {
    func observeBalances() -> Observable<[BalancePicker.Model.Balance]>
}

extension BalancePicker {
    typealias BalancesFetcherProtocol = BalancePickerBalancesFetcherProtocol
    
    class BalancesFetcher {
        
        // MARK: - Private properties
        
        private let ownerAccountId: String
        private let balancesRepo: BalancesRepo
        private let assetsRepo: AssetsRepo
        private let imagesUtility: ImagesUtility
        private let targetAssets: [String]
        
        private let balancesRelay: BehaviorRelay<[Model.Balance]> = BehaviorRelay(value: [])
        
        private var balances: [BalancesRepo.BalanceDetails] = []
        private var assets: [AssetsRepo.Asset] = []
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        init(
            ownerAccountId: String,
            balancesRepo: BalancesRepo,
            assetsRepo: AssetsRepo,
            imagesUtility: ImagesUtility,
            targetAssets: [String]
            ) {
            
            self.ownerAccountId = ownerAccountId
            self.balancesRepo = balancesRepo
            self.assetsRepo = assetsRepo
            self.imagesUtility = imagesUtility
            self.targetAssets = targetAssets
        }
        
        // MARK: - Private
        
        private func getAssetName(code: String) -> String {
            let asset = self.assetsRepo.assetsValue.first(where: { (asset) -> Bool in
                return asset.code == code
            })
            return asset?.defaultDetails?.name ?? code
        }
        
        private func observeBalancesRepo() {
            self.balancesRepo
                .observeConvertedBalancesStates()
                .subscribe(onNext: { [weak self] (states) in
                    self?.balances = states.compactMap({ (state) -> BalancesRepo.BalanceDetails? in
                        switch state {
                            
                        case .created(let balance):
                            return balance
                            
                        case .creating:
                            return nil
                        }
                    })
                    self?.updateBalances()
                })
                .disposed(by: self.disposeBag)
        }
        
        private func observeAssetsRepo() {
            self.assetsRepo
                .observeAssets()
                .subscribe(onNext: { [weak self] (assets) in
                    self?.assets = assets
                    self?.updateBalances()
                })
                .disposed(by: self.disposeBag)
        }
        
        private func updateBalances() {
            var balances: [Model.Balance] = []
            
            self.balances.forEach { (balance) in
                let assetName = self.getAssetName(code: balance.asset)
                if let asset = self.assets.first(where: { (asset) -> Bool in
                    return asset.code == balance.asset
                        && asset.owner == self.ownerAccountId
                        && self.targetAssets.contains(assetName)
                        && balance.balance > 0
                }) {
                    let balance = Model.BalanceDetails(
                        amount: balance.balance,
                        balanceId: balance.balanceId
                    )
                    var iconUrl: URL?
                    if let key = asset.defaultDetails?.logo?.key {
                        let imageKey = ImagesUtility.ImageKey.key(key)
                        iconUrl = self.imagesUtility.getImageURL(imageKey)
                    }
                    let balanceModel = Model.Balance(
                        assetCode: assetName,
                        iconUrl: iconUrl,
                        details: balance
                    )
                    balances.append(balanceModel)
                }
            }
            self.balancesRelay.accept(balances)
        }
    }
}

extension BalancePicker.BalancesFetcher: BalancePicker.BalancesFetcherProtocol {
    
    func observeBalances() -> Observable<[BalancePicker.Model.Balance]> {
        self.observeBalancesRepo()
        self.observeAssetsRepo()
        return self.balancesRelay.asObservable()
    }
}
