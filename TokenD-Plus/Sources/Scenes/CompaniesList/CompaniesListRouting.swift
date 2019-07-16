import Foundation

extension CompaniesList {
    
    public struct Routing {
        let showLoading: () -> Void
        let hideLoading: () -> Void
        let showShadow: () -> Void
        let hideShadow: () -> Void
        let onCompanyChosen: (
        _ ownerAccountId: String,
        _ companyName: String
        ) -> Void
    }
}
