import UIKit

class LocalizationManager {
    
    // MARK: - Public properties
    
    public static let languageKey: String = "language"
    
    // MARK: - Private properties
    
    private static let userDefaults = UserDefaults.standard
    
    // MARK: - Public
    
    static func localizedString(key: LocKey) -> String {
        let bundle = LocalizationManager.getBundle()
        return NSLocalizedString(key.rawValue, bundle: bundle, value: "", comment: "")
    }
    
    static func localizedAttributedString(
        key: LocKey,
        attributes: [NSAttributedString.Key: Any]?,
        replace: [LocKey: NSAttributedString]
        ) -> NSAttributedString {
        
        let localizedString = self.localizedString(key: key)
        let localizedAttributedString = NSMutableAttributedString(
            string: localizedString,
            attributes: attributes
        )
        
        for (key, value) in replace {
            let keyValue = key.rawValue
            
            guard let startIndex = keyValue.endIndex(of: "replace_") else {
                continue
            }
            
            let valueName = key.rawValue[startIndex...]
            let replaceKey = "$(\(valueName))"
            
            var replaceStringRange = localizedAttributedString.string.range(of: replaceKey)
            while replaceStringRange != nil {
                guard let replaceRange = replaceStringRange else {
                    continue
                }
                
                let location: Int = localizedAttributedString.string.distance(
                    from: localizedAttributedString.string.startIndex,
                    to: replaceRange.lowerBound
                )
                
                let length: Int = localizedAttributedString.string.distance(
                    from: replaceRange.lowerBound,
                    to: replaceRange.upperBound
                )
                
                let nsRange = NSRange(location: location, length: length)
                localizedAttributedString.deleteCharacters(in: nsRange)
                localizedAttributedString.insert(value, at: location)
                
                replaceStringRange = localizedAttributedString.string.range(of: replaceKey)
            }
        }
        
        return localizedAttributedString
    }
    
    static func localizedString(key: LocKey, replace: [LocKey: String]) -> String {
        let bundle = LocalizationManager.getBundle()
        var localizedString = NSLocalizedString(key.rawValue, bundle: bundle, value: "", comment: "")
        
        for (key, value) in replace {
            let keyValue = key.rawValue
            
            guard let startIndex = keyValue.endIndex(of: "replace_") else {
                continue
            }
            
            let valueName = key.rawValue[startIndex...]
            let replaceKey = "$(\(valueName))"
            
            localizedString = localizedString.replacingOccurrences(
                of: replaceKey,
                with: value
            )
        }
        
        return localizedString
    }
    
    // MARK: - Private
    
    private static func getBundle() -> Bundle {
        var bundle = Bundle.main
        if let language =  LocalizationManager.userDefaults.string(forKey: LocalizationManager.languageKey),
            let customBundlePath = bundle.path(forResource: language, ofType: "lproj"),
            let customBundle = Bundle(path: customBundlePath) {
            
            bundle = customBundle
        }
        return bundle
    }
}

// swiftlint:disable identifier_name
func Localized(_ key: LocKey) -> String {
    return LocalizationManager.localizedString(key: key)
}

func Localized(_ key: LocKey, replace: [LocKey: String]) -> String {
    return LocalizationManager.localizedString(key: key, replace: replace)
}

func LocalizedAtrributed(
    _ key: LocKey,
    attributes: [NSAttributedString.Key: Any]?,
    replace: [LocKey: NSAttributedString]
    ) -> NSAttributedString {
    
    return LocalizationManager.localizedAttributedString(
        key: key,
        attributes: attributes,
        replace: replace
    )
}
// swiftlint:enable identifier_name
