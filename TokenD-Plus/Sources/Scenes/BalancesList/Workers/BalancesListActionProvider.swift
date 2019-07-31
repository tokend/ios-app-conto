import Foundation

public protocol BalancesListActionsProviderProtocol {
    func getActions() -> [BalancesList.Model.ActionModel]
}

extension BalancesList {
    public typealias ActionsProviderProtocol = BalancesListActionsProviderProtocol
    
    public class ActionProvider: ActionsProviderProtocol  {
        
        private let originalAccountId: String
        private let ownerAccountId: String
        
        public init(
            originalAccountId: String,
            ownerAccountId: String
            ) {
            
            self.originalAccountId = originalAccountId
            self.ownerAccountId = ownerAccountId
        }
        
        
        public func getActions() -> [BalancesList.Model.ActionModel] {
            var actions: [BalancesList.Model.ActionModel] = []
            let receiveAction = Model.ActionModel(
                title: Localized(.receive),
                image: Assets.receive.image,
                actionType: .receive
            )
            actions.append(receiveAction)
            
            let sendAction = Model.ActionModel(
                title: Localized(.send),
                image: Assets.send.image,
                actionType: .send
            )
            actions.append(sendAction)
            
            let createRedeem = Model.ActionModel(
                title: Localized(.redeem),
                image: Assets.redeem.image,
                actionType: .createRedeem
            )
            actions.append(createRedeem)
            
            if self.ownerAccountId == self.originalAccountId {
                let acceptRedeem = Model.ActionModel(
                    title: Localized(.accept_redemption),
                    image: Assets.scanQrIcon.image,
                    actionType: .acceptRedeem
                )
                actions.append(acceptRedeem)
            }
            
            return actions
        }
    }
}
