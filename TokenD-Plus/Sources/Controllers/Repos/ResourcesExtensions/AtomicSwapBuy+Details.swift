import TokenDSDK

extension AtomicSwapBuyResource {
    
    var fiatDetails: FiatDetails? {
        let details = self.data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: details, options: []) else {
            return nil
        }
        
        guard let fiatDetails = try? JSONDecoder().decode(
            FiatDetails.self,
            from: jsonData
            ) else { return nil }
        
        return fiatDetails
    }
    
    var cryptoDetails: CryptoDetails? {
        let details = self.data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: details, options: []) else {
            return nil
        }
        
        guard let cryptoDetails = try? JSONDecoder().decode(
            CryptoDetails.self,
            from: jsonData
            ) else { return nil }
        
        return cryptoDetails
    }
}

extension AtomicSwapBuyResource {
    
    struct FiatDetails: Decodable {
        let pay_url: String
    }
    
    struct CryptoDetails: Decodable {
        let address: String
        let amount: String
    }
}
