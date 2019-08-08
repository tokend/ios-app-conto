import UIKit

extension TransactionDetails {
    
    public class DateFormatter: DateFormatterProtocol {
        
        // MARK: - Private properties
        
        private let dateFormatter: Foundation.DateFormatter
        
        private let userDefaults: UserDefaults = UserDefaults.standard
        
        private lazy var locale: Locale = {
            if let languageKey = self.userDefaults
                .value(forKey: LocalizationManager.languageKey) as? String {
                return Locale(identifier: languageKey)
            } else {
                return Locale.autoupdatingCurrent
            }
        }()
        
        // MARK: -
        
        public init() {
            self.dateFormatter = Foundation.DateFormatter()
            self.dateFormatter.locale = self.locale
            self.dateFormatter.dateFormat = "dd MMM yyyy h:mm a"
            self.dateFormatter.amSymbol = "AM"
            self.dateFormatter.pmSymbol = "PM"
        }
        
        // MARK: - DateFormatterProtocol
        
        func dateToString(date: Date) -> String {
            return self.dateFormatter.string(from: date)
        }
    }
}
