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
            let redeem: Model.ActionModel
            if self.ownerAccountId == self.originalAccountId {
                redeem = Model.ActionModel(
                    title: Localized(.accept_redeem),
                    image: Assets.scanQrIcon.image,
                    actionType: .acceptRedeem
                )
            } else {
                redeem = Model.ActionModel(
                    title: Localized(.redeem),
                    image: Assets.scanQrIcon.image,
                    actionType: .createRedeem
                )
            }
            
            let sendAction = Model.ActionModel(
                title: Localized(.send),
                image: Assets.send.image,
                actionType: .send
            )
            
            let receiveAction = Model.ActionModel(
                title: Localized(.receive),
                image: Assets.receive.image,
                actionType: .receive
            )
            
            return [sendAction, receiveAction, redeem]
        }
    }
}
