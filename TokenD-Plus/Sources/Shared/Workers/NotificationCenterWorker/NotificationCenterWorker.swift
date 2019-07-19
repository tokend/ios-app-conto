import Foundation

struct NotificationCenterUtil {
    
    // MARK: - Singleton
    
    private init() { }
    
    static let instance: NotificationCenterUtil = NotificationCenterUtil()
    
    // MARK: - Private properties
    
    private let notificationCenter: NotificationCenter = NotificationCenter()
    
    // MARK: - Public methods
    
    func addObserver(forName name: Notification.Name, using: @escaping (Notification) -> Void) {
        notificationCenter.addObserver(forName: name, object: nil, queue: nil, using: using)
    }
    
    func addObserver(_ observer: Any, selector: Selector, name: Notification.Name) {
        notificationCenter.addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    func removeObserver(_ observer: Any) {
        notificationCenter.removeObserver(observer)
    }
    
    func postNotification(_ name: Notification.Name) {
        notificationCenter.post(name: name, object: nil)
    }
}
