import Foundation

protocol SettingsManagerProtocol: class {
    var biometricsAuthEnabled: Bool { get set }
    var businessOwnerAccountId: String? { get set }
    var businessName: String? { get set }
    var businessImageKey: String? { get set }
    var businessConversionAsset: String? { get set }
    
    func cleanAccountRelatedInfo()
}

class SettingsManager {
    
    // MARK: - Public properties
    
    static let biometricsAuthEnabledUserDefaultsKey: String = "biometricsAuthEnabled"
    static let businessOwnerAccountIdKey: String = "businessOwnerAccountId"
    static let businessNameKey: String = "businessName"
    static let businessImageKey: String = "businessImage"
    static let businessConversionAssetKey: String = "businessConversionAsset"
    
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
    
    var businessImageKey: String? {
        get {
            return self.getBusinessImageKey()
        }
        set {
            self.setBusinessImageKey(imageKey: newValue)
        }
    }
    
    var businessConversionAsset: String? {
        get {
            return self.getBusinessConversionAsset()
        }
        set {
            self.setBusinessConversionAsset(conversionAsset: newValue)
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
    
    private func getBusinessImageKey() -> String? {
        return self.userDefaults.string(forKey: SettingsManager.businessImageKey)
    }
    
    private func setBusinessImageKey(imageKey: String?) {
        self.userDefaults.setValue(imageKey, forKey: SettingsManager.businessImageKey)
    }
    
    private func getBusinessConversionAsset() -> String? {
        return self.userDefaults.string(forKey: SettingsManager.businessConversionAssetKey)
    }
    
    private func setBusinessConversionAsset(conversionAsset: String?) {
        self.userDefaults.setValue(conversionAsset, forKey: SettingsManager.businessConversionAssetKey)
    }
}

extension SettingsManager: SettingsManagerProtocol {
    
    public func cleanAccountRelatedInfo() {
        self.businessOwnerAccountId = nil
        self.businessName = nil
        self.businessImageKey = nil
        self.businessConversionAsset = nil
    }
}
