import Foundation

extension TabBar {
    
    class GlobalNavigationTabProvider: TabProviderProtocol {
        
        // MARK: - Private
        
        private let ownerAccountId: String
        private let originalAccountId: String
        
        // MARK: -
        
        init(
            ownerAccountId: String,
            originalAccountId: String
            ) {
            
            self.ownerAccountId = ownerAccountId
            self.originalAccountId = originalAccountId
        }
        
        // MARK: - TabProviderProtocol
        
        func getTabs() -> [TabBar.Model.TabItem] {
            let balancesTab = Model.TabItem(
                title: Localized(.balances),
                image: Assets.amount.image,
                identifier: Localized(.balances),
                isSelectable: true
            )
            let salesTab = Model.TabItem(
                title: Localized(.sales),
                image: Assets.exploreFundsIcon.image,
                identifier: Localized(.sales),
                isSelectable: true
            )
            let pollsTab = Model.TabItem(
                title: Localized(.polls),
                image: Assets.polls.image,
                identifier: Localized(.polls),
                isSelectable: true
            )
            let settingsTab = Model.TabItem(
                title: Localized(.settings),
                image: Assets.settingsIcon.image,
                identifier: Localized(.settings),
                isSelectable: true
            )
            
            let otherActions = self.getOtherActions()
            let otherTab = Model.TabItem(
                title: Localized(.other),
                image: Assets.menuIcon.image,
                actions: otherActions,
                identifier: Localized(.other),
                isSelectable: false
            )
            
            return [balancesTab, salesTab, pollsTab, settingsTab, otherTab]
        }
        
        private func getOtherActions() -> [Model.ActionModel] {
            var actions: [Model.ActionModel] = []
            let companiesAction = Model.ActionModel(
                title: Localized(.companies),
                icon: Assets.companies.image,
                actionIdentifier: Localized(.companies)
            )
            actions.append(companiesAction)
            
            let sendAction = Model.ActionModel(
                title: Localized(.send),
                icon: Assets.send.image,
                actionIdentifier: Localized(.send)
            )
            actions.append(sendAction)
            
            let receiveAction = Model.ActionModel(
                title: Localized(.receive),
                icon: Assets.receive.image,
                actionIdentifier: Localized(.receive)
            )
            actions.append(receiveAction)
            
            let createRedeem = Model.ActionModel(
                title: Localized(.redeem),
                icon: Assets.redeem.image,
                actionIdentifier: Localized(.redeem)
            )
            actions.append(createRedeem)
            
            if self.ownerAccountId == self.originalAccountId {
                let acceptRedeem = Model.ActionModel(
                    title: Localized(.accept_redemption),
                    icon: Assets.scanQrIcon.image,
                    actionIdentifier: Localized(.accept_redemption)
                )
                actions.append(acceptRedeem)
            }
            
            return actions
        }
    }
}
