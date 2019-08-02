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
        let showError: (_ errorMessage: String) -> Void
        let showSuccessMessage: (_ message: String) -> Void
        let onPresentQRCodeReader: (_ completion: @escaping QRCodeReaderCompletion) -> Void
        let onAddCompany: (
        _ company: Model.Company,
        _ completion: @escaping AddCompanyCompletion
        ) -> Void
    }
}
