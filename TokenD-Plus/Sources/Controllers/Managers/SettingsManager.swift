import Foundation

protocol SettingsManagerProtocol: class {
    var biometricsAuthEnabled: Bool { get set }
    var businessOwnerAccountId: String? { get set }
    var businessName: String? { get set }
    
    func cleanAccountRelatedInfo()
}

class SettingsManager {
    
    // MARK: - Public properties
    
    static let biometricsAuthEnabledUserDefaultsKey: String = "biometricsAuthEnabled"
    static let businessOwnerAccountIdKey: String = "businessOwnerAccountId"
    static let businessNameKey: String = "businessName"
    
    var biometricsAuthEnabled: Bool {
        get {
            return self.getBiometricsAuthEnabled()
        }
        set {
            self.setBiometricsAuthEnabled(newValue)
        }
    }
    
    var businessOwnerAccountId: String? {
        get {
            return self.getBusinessOwnerAccountId()
        }
        set {
            self.setBusinessOwnerAccountId(ownerAccountId: newValue)
        }
    }
    
    var businessName: String? {
        get {
            return self.getBusinessName()
        }
        set {
            self.setBusinessName(name: newValue)
        }
    }
    
    // MARK: - Private properties
    
    let userDefaults: UserDefaults = UserDefaults.standard
    
    // MARK: -
    
    init() {
        
    }
    
    // MARK: - Private
    
    private func getBiometricsAuthEnabled() -> Bool {
        guard self.userDefaults.object(forKey: SettingsManager.biometricsAuthEnabledUserDefaultsKey) != nil else {
            // Biometrics are enabled by default
            return true
        }
        
        return self.userDefaults.bool(forKey: SettingsManager.biometricsAuthEnabledUserDefaultsKey)
    }
    
    private func setBiometricsAuthEnabled(_ enabled: Bool) {
        self.userDefaults.set(enabled, forKey: SettingsManager.biometricsAuthEnabledUserDefaultsKey)
    }
    
    private func getBusinessOwnerAccountId() -> String? {
        return self.userDefaults.string(forKey: SettingsManager.businessOwnerAccountIdKey)
    }
    
    private func setBusinessOwnerAccountId(ownerAccountId: String?) {
        self.userDefaults.setValue(ownerAccountId, forKey: SettingsManager.businessOwnerAccountIdKey)
    }
    
    private func getBusinessName() -> String? {
        return self.userDefaults.string(forKey: SettingsManager.businessNameKey)
    }
    
    private func setBusinessName(name: String?) {
        self.userDefaults.setValue(name, forKey: SettingsManager.businessNameKey)
    }
}

extension SettingsManager: SettingsManagerProtocol {
    
    public func cleanAccountRelatedInfo() {
        self.userDefaults.set(nil, forKey: SettingsManager.businessNameKey)
        self.userDefaults.set(nil, forKey: SettingsManager.businessOwnerAccountIdKey)
    }
}
