import Foundation
import TokenDSDK

extension AssetResource {
    
    var name: String? {
        return self.details["name"] as? String
    }
    
    var customDetails: CustomDetails? {
        let details = self.details
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: details, options: []) else {
            return nil
        }
        
        guard let customDetails = try? JSONDecoder().decode(CustomDetails.self, from: jsonData) else {
            return nil
        }
        
        return customDetails
    }
}

extension AssetResource {
    
    struct CustomDetails: Decodable {
        let logo: Logo?
    }
}

extension AssetResource.CustomDetails {
    
    struct Logo: Decodable {
        
        let key: String
    }
}

