import Foundation

public protocol EnvironmentChangeWorkerProtocol {
    func getAvailableEnvironments() -> [String]
    func checkIfCurrent(environment: String) -> Bool
    func setCurrentEnvironmnet(environment: String)
}

public class EnvironmentChangeWorker: EnvironmentChangeWorkerProtocol {
    
    // MARK: - Private properties
    
    private let settingsManager: SettingsManagerProtocol
    
    // MARK: -
    
    init(settingsManager: SettingsManagerProtocol) {
        self.settingsManager = settingsManager
    }
    
    // MARK: - EnvironmentChangeWorkerProtocol
    
    public func getAvailableEnvironments() -> [String] {
        return APIConfigurationModel.Environment.allCases.map({ (environment) -> String in
            return environment.rawValue
        })
    }
    
    public func checkIfCurrent(environment: String) -> Bool {
        guard let currentEnvironment = self.settingsManager.environment else {
            return false
        }
        return currentEnvironment == environment
    }
    
    public func setCurrentEnvironmnet(environment: String) {
        self.settingsManager.environment = environment
    }
}
