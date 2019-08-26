import Foundation

extension TransactionsListScene {
    
    public class EmptyActionsProvider: ActionProviderProtocol {
        
        func getActions(asset: String) -> [TransactionsListScene.ActionModel] {
            return []
        }
        
        func getActions(balanceId: String) -> [TransactionsListScene.ActionModel] {
            return []
        }
    }
}
