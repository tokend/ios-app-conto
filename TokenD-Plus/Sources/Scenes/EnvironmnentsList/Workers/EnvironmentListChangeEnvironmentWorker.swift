import Foundation

public enum ChangeEnvironmentResult {
    case changed
    case alreadyInThisEnvironment(environment: String)
}
public protocol EnvironmentsListChangeEnvironmentWorkerProtocol {
    func changeEnvironment(
        environment: EnvironmentsList.Model.Environment,
        completion: @escaping (ChangeEnvironmentResult) -> Void
    )
}

extension EnvironmentsList {
    public typealias ChangeEnvironmentWorkerProtocol = EnvironmentsListChangeEnvironmentWorkerProtocol
    
    public class ChangeEnvironmentWorker: ChangeEnvironmentWorkerProtocol {
        
        // MARK: - Private properties
        
        private let userDefaults: UserDefaults = UserDefaults.standard
        private let environmentKey: String = UserDefaults.environmentKey
        
        // MARK: - ChangeEnvironmentWorkerProtocol
        
        private func getApiConfigurationFor(
            environment: EnvironmentsList.Model.Environment
            ) -> APIConfigurationModel {
            
            switch environment {
                
            case .demo:
                return APIConfigurationModel
                    .apiConfigurationFor(environment: .demo)
                
            case .production:
               return APIConfigurationModel
                .apiConfigurationFor(environment: .production)
            }
        }
        
        public func changeEnvironment(
            environment: EnvironmentsList.Model.Environment,
            completion: @escaping (ChangeEnvironmentResult) -> Void
            ) {
            
            guard let storedEnvironment = self.userDefaults.value(forKey: self.environmentKey) as? String else {
                self.userDefaults.set(
                    APIConfigurationModel.Environment.production.rawValue,
                    forKey: UserDefaults.environmentKey
                )
                completion(.changed)
                return
            }
            guard storedEnvironment != environment.rawValue else {
                completion(.alreadyInThisEnvironment(environment: storedEnvironment))
                return
            }
            self.userDefaults.set(
                environment.rawValue,
                forKey: self.environmentKey
            )
            completion(.changed)
        }
    }
}

public extension UserDefaults {
    static let environmentKey: String = "environment"
}
