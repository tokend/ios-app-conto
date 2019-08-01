import Foundation

extension AddCompany {
    public struct Routing {
        let onAddActionResult: (_ result: Model.AddCompanyResult) -> Void
        let onCancel: () -> Void
        let showLoading: () -> Void
        let hideLoading: () -> Void
    }
}
