import Foundation

extension CompaniesList {
    
    public struct Routing {
        let showLoading: () -> Void
        let hideLoading: () -> Void
        let onCompanyChosen: (_ ownerAccountId: String) -> Void
    }
}
