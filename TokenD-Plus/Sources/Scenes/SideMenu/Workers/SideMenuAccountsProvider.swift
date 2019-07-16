import Foundation

protocol SideMenuAccountsProviderProtocol {
    func getAccountItems(completion: @escaping ([SideMenu.Model.AccountItem]) -> Void)
}

extension SideMenu {
    typealias AccountsProviderProtocol = SideMenuAccountsProviderProtocol
    
    class AccountsProvider: AccountsProviderProtocol {
        
        // MARK: - AccountsProviderProtocol
        
        func getAccountItems(completion: @escaping ([SideMenu.Model.AccountItem]) -> Void) {
            
            let itemA = Model.AccountItem(
                name: "UA Hardware",
                image: Assets.walletIcon.image,
                ownerAccountId: "GBA4EX43M25UPV4WIE6RRMQOFTWXZZRIPFAI5VPY6Z2ZVVXVWZ6NEOOB"
                )
            let itemB = Model.AccountItem(
                name: "Pub Lolek",
                image: Assets.upcomingImage.image,
                ownerAccountId: "GDLWLDE33BN7SG6V4P63V2HFA56JYRMODESBLR2JJ5F3ITNQDUVKS2JE"
            )
            
            completion([itemA, itemB])
        }
    }
}
