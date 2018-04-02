import Foundation

class SettingDefaults {
    func add(value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func removeValueAt(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func valueFor(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
}
