import Foundation

public enum ChangeLanguageResult {
    case success
    case failure(Error)
    
    public enum Error: Swift.Error {
        case languageNotFound
    }
}
public protocol LanguagesListChangeLanguageWorkerProtocol {
    func changeLanguage(
        code: String,
        completion: @escaping (ChangeLanguageResult) -> Void
    )
}

extension LanguagesList {
    public typealias ChangeLanguageWorkerProtocol = LanguagesListChangeLanguageWorkerProtocol
    
    public class ChangeLanguageWorker: ChangeLanguageWorkerProtocol {
        
        // MARK: - Private properties
        
        private let userDefaults: UserDefaults = UserDefaults.standard
        private let languageKey: String = LocalizationManager.languageKey
        
        // MARK: - ChangeLanguageWorkerProtocol
        
        public func changeLanguage(
            code: String,
            completion: @escaping (ChangeLanguageResult) -> Void
            ) {
            
            let accessibleLanguages = Bundle.main.localizations
            if accessibleLanguages.contains(code) {
                self.userDefaults.set(code, forKey: self.languageKey)
                DispatchQueue.main.async {
                    NotificationCenterUtil
                        .instance
                        .postNotification(Notification.Name("LCLLanguageChangeNotification"))
                }
                completion(.success)
            } else {
                completion(.failure(.languageNotFound))
            }
        }
    }
}
