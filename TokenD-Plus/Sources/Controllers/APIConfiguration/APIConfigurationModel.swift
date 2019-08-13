import Foundation

public struct APIConfigurationModel: Decodable, Equatable {
    let storageEndpoint: String
    let apiEndpoint: String
    let contributeUrl: String?
    let termsAddress: String?
    let webClient: String?
    let downloadUrl: String?
    
    public enum Environment: String {
        case production = "Production"
        case demo = "Demo"
    }
}

extension APIConfigurationModel {
    
    static func apiConfigurationFor(environment: EnvironmentsList.Model.Environment) -> APIConfigurationModel {
        
        switch environment {
            
        case .demo:
            return APIConfigurationModel(
                storageEndpoint: "https://53133ee4.ngrok.io/_/storage/api",
                apiEndpoint: "https://53133ee4.ngrok.io/_/api/",
                contributeUrl: "https://github.com/tokend/ios-app-loyalty",
                termsAddress: nil,
                webClient: nil,
                downloadUrl: nil
            )
            
        case .production:
            return APIConfigurationModel(
                storageEndpoint: "https://s3.eu-north-1.amazonaws.com/contostaging-identity-storage-festive-cannon-2",
                apiEndpoint: "https://api.staging.conto.me/",
                contributeUrl: "https://github.com/tokend/ios-app-loyalty",
                termsAddress: nil,
                webClient: nil,
                downloadUrl: nil
            )
        }
    }
    
    static func getLatestApiConfigutarion() -> APIConfigurationModel {
        let apiConfigurationModel: APIConfigurationModel
        if let environmentString = UserDefaults.standard.string(forKey: UserDefaults.environmentKey),
            let environment = APIConfigurationModel.Environment.init(rawValue: environmentString) {
            apiConfigurationModel = APIConfigurationModel.apiConfigurationFor(environment: environment)
        } else {
            UserDefaults.standard.set(
                APIConfigurationModel.Environment.production.rawValue,
                forKey: UserDefaults.environmentKey
            )
            apiConfigurationModel = APIConfigurationModel.apiConfigurationFor(environment: .production)
        }
        return apiConfigurationModel
    }
}

