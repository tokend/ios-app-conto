import Foundation

struct ApiConfigurationDataProvider {
    
    // MARK: - Public properties
    
    let apiConfigurationModel: APIConfigurationModel
    let settingsManager: SettingsManagerProtocol
    
    // MARK: -
    
    init(
        apiConfigurationModel: APIConfigurationModel,
        settingsManager: SettingsManagerProtocol
        ) {
        
        self.apiConfigurationModel = apiConfigurationModel
        self.settingsManager = settingsManager
    }
    
    // MARK: - Public
    
    func getTermsUrl() -> URL? {
        var termsUrl: URL?
        if var termsAddress = self.apiConfigurationModel.termsAddress {
            if !(termsAddress.hasPrefix("http://") || termsAddress.hasPrefix("https://")) {
                termsAddress = "https://\(termsAddress)"
            }
            termsUrl = URL(string: termsAddress)
        }
        
        return termsUrl
    }
    
    func getEnvironment() -> String? {
        return self.settingsManager.environment
    }
}
