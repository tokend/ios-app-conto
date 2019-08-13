import Foundation

extension EnvironmentsList {
    public struct Routing {
        let onEnvironmentChanged: () -> Void
        let showMessage: (_ message: String) -> Void
    }
}
