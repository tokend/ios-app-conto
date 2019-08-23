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
        
        private let balancesRepo: BalancesRepo
        private let originalAccountId: String
        
        // MARK: -
        
        init(
            balancesRepo: BalancesRepo,
            originalAccountId: String
            ) {
            
            self.balancesRepo = balancesRepo
            self.originalAccountId = originalAccountId
        }
    }
}

extension TransactionsListScene.ActionProvider: TransactionsListScene.ActionProviderProtocol {
    
    func getActions(asset: String) -> [TransactionsListScene.ActionModel] {
        var actions: [TransactionsListScene.ActionModel] = []
        guard
            let state = self.balancesRepo.convertedBalancesStatesValue.first(where: { (state) -> Bool in
            return state.balance?.asset?.id == asset
        }), let assetResource = state.balance?.asset,
            let assetOwner = assetResource.owner?.id else {
                return []
        }
        
        let receiveAction = TransactionsListScene.ActionModel(
            title: Localized(.receive),
            image: Assets.receive.image,
            type: .receive
        )
        if
            let balanceId = state.balance?.id,
            let balance = state.initialAmounts {
            
            if balance.available > 0 {
                let sendAction = TransactionsListScene.ActionModel(
                    title: Localized(.send),
                    image: Assets.paymentAction.image,
                    type: .send(balanceId: balanceId)
                )
                actions.append(sendAction)
                actions.append(receiveAction)
                
                if assetOwner == self.originalAccountId {
                    let acceptRedeemAction = TransactionsListScene.ActionModel(
                        title: Localized(.accept_redemption),
                        image: Assets.scanQrIcon.image,
                        type: .acceptRedeem
                    )
                    actions.append(acceptRedeemAction)
                } else {
                    let createRedeemAction = TransactionsListScene.ActionModel(
                        title: Localized(.redeem),
                        image: Assets.redeem.image,
                        type: .createRedeem(balanceId: balanceId)
                    )
                    actions.append(createRedeemAction)
                }
            }
        } else {
            actions.append(receiveAction)
        }
        
        return actions
    }
    
    func getActions(balanceId: String) -> [TransactionsListScene.ActionModel] {
        var actions: [TransactionsListScene.ActionModel] = []
        guard
            let state = self.balancesRepo.convertedBalancesStatesValue.first(where: { (state) -> Bool in
                return state.balance?.id == balanceId
            }),
            let balance = state.initialAmounts,
            let balanceId = state.balance?.id,
            let assetResource = state.balance?.asset,
            let assetOwner = assetResource.owner?.id else {
                return []
        }
        
        let receiveAction = TransactionsListScene.ActionModel(
            title: Localized(.receive),
            image: Assets.receive.image,
            type: .receive
        )
        
        if balance.available > 0 {
            let sendAction = TransactionsListScene.ActionModel(
                title: Localized(.send),
                image: Assets.paymentAction.image,
                type: .send(balanceId: balanceId)
            )
            actions.append(sendAction)
            actions.append(receiveAction)
        } else {
            actions.append(receiveAction)
        }
        
        if assetOwner == self.originalAccountId {
            let acceptRedeemAction = TransactionsListScene.ActionModel(
                title: Localized(.accept_redemption),
                image: Assets.scanQrIcon.image,
                type: .acceptRedeem
            )
            actions.append(acceptRedeemAction)
        } else {
            if balance.available > 0 {
                let createRedeemAction = TransactionsListScene.ActionModel(
                    title: Localized(.redeem),
                    image: Assets.redeem.image,
                    type: .createRedeem(balanceId: balanceId)
                )
                actions.append(createRedeemAction)
            }
        }
        
        return actions
    }
}
