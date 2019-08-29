import Foundation
import TokenDSDK

enum VerifyEmailVerifyResult {
    case succeded
    case failed(Swift.Error)
}

enum VerifyEmailVerificationStateResult {
    case verified
}

protocol VerifyEmailVerifyWorkerProtocol {
    typealias Result = VerifyEmailVerifyResult
    
    func performVerifyRequest(
        token: String,
        completion: @escaping (_ result: Result) -> Void
    )
    
    func verifyEmailTokenFrom(url: URL) -> String?
    
    func checkVerificationState(
        completion: @escaping (_ result: VerifyEmailVerificationStateResult) -> Void
    )
}
