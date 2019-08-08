import Foundation
import TokenDSDK

extension AssetResource {
    
    var name: String? {
        return self.details["name"] as? String
    }
}
