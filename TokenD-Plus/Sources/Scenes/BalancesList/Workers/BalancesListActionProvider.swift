import Foundation

public protocol BalancesListActionsProviderProtocol {
    func getActions() -> [BalancesList.Model.ActionModel]
}

extension BalancesList {
    public typealias ActionsProviderProtocol = BalancesListActionsProviderProtocol
    
    public class ActionProvider: ActionsProviderProtocol  {
        
        public func getActions() -> [BalancesList.Model.ActionModel] {
            let redeem = Model.ActionModel(
                title: Localized(.redeem),
                image: Assets.scanQrIcon.image,
                actionType: .redeem
            )
            
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
            
            return [redeem, sendAction, receiveAction]
        }
    }
}
