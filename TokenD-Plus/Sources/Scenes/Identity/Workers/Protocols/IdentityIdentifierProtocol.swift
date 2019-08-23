import Foundation

public enum IdentifyResult {
    case didNotSet
    case value(String)
    case error(Swift.Error)
}
public protocol IdentityIdentifierProtocol {
    func identifyBy(
        accountId: String,
        completion: @escaping(IdentifyResult) -> Void
    )
}
