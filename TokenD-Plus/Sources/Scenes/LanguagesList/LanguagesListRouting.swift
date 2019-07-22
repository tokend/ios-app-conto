import Foundation

extension LanguagesList {
    public struct Routing {
        let showError: (String) -> Void
        let onLanguageChanged: () -> Void
    }
}
