import Foundation

extension UserDefaults {
    
    static func mocked(for name: String) -> UserDefaults {
        guard let userDefaults = UserDefaults(suiteName: name) else {
            fatalError("Couldn't initialize UserDefaults with specified name: \(name)")
        }
        
        userDefaults.removePersistentDomain(forName: name)
        return userDefaults
    }
}
