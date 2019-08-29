import Foundation
import RxCocoa
import RxSwift

protocol AssetPickerAssetsFetcherProtocol {
    func observeAssets() -> Observable<[AssetPicker.Model.Asset]>
}

extension AssetPicker {
    typealias AssetsFetcherProtocol = AssetPickerAssetsFetcherProtocol
    
    class AssetsFetcher {
        
        // MARK: - Private properties
        
        private let assetsRepo: AssetsRepo
        private let imagesUtility: ImagesUtility
        
        private let assetsRelay: BehaviorRelay<[Model.Asset]> = BehaviorRelay(value: [])
        private var assets: [AssetsRepo.Asset] = []
        private var targetAssets: [String]?
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        init(
            assetsRepo: AssetsRepo,
            imagesUtility: ImagesUtility,
            targetAssets: [String]?
            ) {
            
            self.assetsRepo = assetsRepo
            self.imagesUtility = imagesUtility
            self.targetAssets = targetAssets
        }
        
        // MARK: - Private
        
        private func observeAssetsRepo() {
            self.assetsRepo
                .observeAssets()
                .subscribe(onNext: { [weak self] (assets) in
                    self?.assets = assets
                    self?.updateAssets()
                })
                .disposed(by: self.disposeBag)
        }
        
        private func updateAssets() {
            var assets = self.assets.map { (asset) -> Model.Asset in
                var iconUrl: URL?
                if let key = asset.defaultDetails?.logo?.key {
                    let imageKey = ImagesUtility.ImageKey.key(key)
                    iconUrl = self.imagesUtility.getImageURL(imageKey)
                }
                return Model.Asset(
                    name: asset.defaultDetails?.name ?? asset.code,
                    iconUrl: iconUrl,
                    ownerAccountId: asset.owner
                )
            }
            
            if let targetAssets = self.targetAssets {
                assets = assets.filter({ (asset) -> Bool in
                    return targetAssets.contains(asset.name)
                })
            }
            
            self.assetsRelay.accept(assets)
        }
    }
}

extension AssetPicker.AssetsFetcher: AssetPicker.AssetsFetcherProtocol {
    
    func observeAssets() -> Observable<[AssetPicker.Model.Asset]> {
        self.observeAssetsRepo()
        return self.assetsRelay.asObservable()
    }
}
