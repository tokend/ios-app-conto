import Foundation

extension TabBar {
    
    class GlobalNavigationTabProvider: TabProviderProtocol {
        
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
            let companiesTab = Model.TabItem(
                title: Localized(.companies),
                image: Assets.companies.image,
                identifier: Localized(.companies),
                isSelectable: false
            )
            
            return [balancesTab, salesTab, pollsTab, settingsTab, companiesTab]
        }
    }
}
