import Foundation
import TokenDSDK

public enum IdentitySubmitResult {
    case success
    case error(Swift.Error)
}
public protocol IdentityIdentitySubmitWorkerProtocol {
    func submitIdentity(
        value: String,
        completion: @escaping (IdentitySubmitResult) -> Void
    )
}
