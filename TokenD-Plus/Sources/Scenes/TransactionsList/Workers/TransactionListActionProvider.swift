import UIKit
import TokenDWallet

protocol TransactionListSceneActionProviderProtocol {
    func getActions(asset: String) -> [TransactionsListScene.ActionModel]
    func getActions(balanceId: String) -> [TransactionsListScene.ActionModel]
}
extension TransactionsListScene {
    typealias ActionProviderProtocol = TransactionListSceneActionProviderProtocol
    
    struct ActionModel {
        let title: String
        let image: UIImage
        let enabled: Bool
        let type: Model.ActionType
        
        init(
            title: String,
            image: UIImage,
            enabled: Bool = true,
            type: Model.ActionType
            ) {
            
            self.title = title
            self.image = image
            self.enabled = enabled
            self.type = type
        }
    }
    
    class ActionProvider {
        
        // MARK: - Private properties
        
        private let assetsRepo: AssetsRepo
        private let balancesRepo: BalancesRepo
        
        // MARK: -
        
        init(
            assetsRepo: AssetsRepo,
            balancesRepo: BalancesRepo
            ) {
            
            self.assetsRepo = assetsRepo
            self.balancesRepo = balancesRepo
        }
    }
}

extension TransactionsListScene.ActionProvider: TransactionsListScene.ActionProviderProtocol {
    
    func getActions(asset: String) -> [TransactionsListScene.ActionModel] {
        var actions: [TransactionsListScene.ActionModel] = []
        guard let asset = self.assetsRepo.assetsValue
            .first(where: { (storedAsset) -> Bool in
                return storedAsset.code == asset
            }) else {
                return []
        }
        
        let receiveAction = TransactionsListScene.ActionModel(
            title: Localized(.receive),
            image: Assets.receive.image,
            type: .receive
        )
        if let state = balancesRepo.balancesDetailsValue
            .first(where: { (state) -> Bool in
                return state.asset == asset.code
            }) {
            
            switch state {
                
            case .created(let details):
                if details.balance > 0 {
                    let sendAction = TransactionsListScene.ActionModel(
                        title: Localized(.send),
                        image: Assets.paymentAction.image,
                        type: .send(balanceId: details.balanceId)
                    )
                    actions.append(sendAction)
                    actions.append(receiveAction)
                    
                }
            case .creating:
                break
            }
        } else {
            actions.append(receiveAction)
        }
        
        return actions
    }
    
    func getActions(balanceId: String) -> [TransactionsListScene.ActionModel] {
        var actions: [TransactionsListScene.ActionModel] = []
        guard
            let details = self.balancesRepo.balancesDetailsValue
                .compactMap({ (state) -> BalancesRepo.BalanceDetails? in
                    switch state {
                    case .created(let details):
                        return details
                        
                    case .creating:
                        return nil
                    }
                }).first(where: { (details) -> Bool in
                    return details.balanceId == balanceId
                }),
            let asset = self.assetsRepo.assetsValue.first(where: { (repoAsset) -> Bool in
                return repoAsset.code == details.asset
            }) else {
                return []
        }
        
        let receiveAction = TransactionsListScene.ActionModel(
            title: Localized(.receive),
            image: Assets.receive.image,
            type: .receive
        )
        
        if details.balance > 0 {
            let sendAction = TransactionsListScene.ActionModel(
                title: Localized(.send),
                image: Assets.paymentAction.image,
                type: .send(balanceId: details.balanceId)
            )
            actions.append(sendAction)
            actions.append(receiveAction)
        } else {
            actions.append(receiveAction)
        }
        
        let buyIsEnabled: Bool =
            Int32(asset.policy) & AssetPolicy.canBeBaseInAtomicSwap.rawValue
                == AssetPolicy.canBeBaseInAtomicSwap.rawValue
        let buyAction = TransactionsListScene.ActionModel(
            title: Localized(.buy),
            image: Assets.buy.image,
            enabled: buyIsEnabled,
            type: .buy(asset: asset.code)
        )
        actions.append(buyAction)
        
        return actions
    }
}
