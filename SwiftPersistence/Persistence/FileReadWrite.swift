import Foundation

struct Persistence {
    private let baseFileName = "AppData.json"
    
    var documentsUrl: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func readAvailableUsers() -> [String: Any]? {
        let fileManager = FileManager.default
        let fileName = "availableUsers-\(baseFileName)"
        
        guard let documentsDirectory = documentsUrl else {
            print("Could not read documents directory")
            return nil
        }
        
        let appDataUrlPath = documentsDirectory.appendingPathComponent(fileName, isDirectory: false).path
        
        guard fileManager.fileExists(atPath: appDataUrlPath) else {
            print("No saved data")
            return nil
        }
        
        guard fileManager.isReadableFile(atPath: appDataUrlPath) else {
            print("Unreadable file")
            return nil
        }
        
        guard let appData = fileManager.contents(atPath: appDataUrlPath) else {
            print("App data contents empty")
            return nil
        }
        
        guard let appDataJson = try? JSONSerialization.jsonObject(with: appData, options: .allowFragments) else {
            print("Could not serialize app data")
            return nil
        }
        
        guard let appDataDictionary = appDataJson as? [String: Any] else {
            print("App data in wrong format")
            return nil
        }
        
        return appDataDictionary
    }
    
    func readUserData(for user: String) -> [String: Any]? {
        let fileManager = FileManager.default
        let fileName = "\(user)-\(baseFileName)"
        
        guard let documentsDirectory = documentsUrl else {
            print("Could not read documents directory")
            return nil
        }
        
        let appDataUrlPath = documentsDirectory.appendingPathComponent(fileName, isDirectory: false).path
        
        guard fileManager.fileExists(atPath: appDataUrlPath) else {
            print("No saved data")
            return nil
        }
        
        guard fileManager.isReadableFile(atPath: appDataUrlPath) else {
            print("Unreadable file")
            return nil
        }
        
        guard let appData = fileManager.contents(atPath: appDataUrlPath) else {
            print("App data contents empty")
            return nil
        }

        guard let appDataJson = try? JSONSerialization.jsonObject(with: appData, options: .allowFragments) else {
            print("Could not serialize app data")
            return nil
        }
        
        guard let appDataDictionary = appDataJson as? [String: Any] else {
            print("App data in wrong format")
            return nil
        }
        
        return appDataDictionary
    }
    
    func writeAvailableUsers(appDataDictionary: [String: Any]) -> Bool {
        guard let documentsDirectory = documentsUrl else {
            print("Could not read documents directory")
            return false
        }
        
        let fileName = "availableUsers-\(baseFileName)"
        
        let writeUrl = documentsDirectory.appendingPathComponent(fileName, isDirectory: false)
        print("\(writeUrl)")
        
        guard let appData = try? JSONSerialization.data(withJSONObject: appDataDictionary, options: .prettyPrinted) else {
            print("Could not serialize dictionary to data")
            return false
        }
        
        do {
            try appData.write(to: writeUrl)
            
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func writeUserData(appDataDictionary: [String: Any], user: String) -> Bool {
        guard let documentsDirectory = documentsUrl else {
            print("Could not read documents directory")
            return false
        }
        
        let fileName = "\(user)-\(baseFileName)"
        
        let writeUrl = documentsDirectory.appendingPathComponent(fileName, isDirectory: false)
        
        guard let appData = try? JSONSerialization.data(withJSONObject: appDataDictionary, options: .prettyPrinted) else {
            print("Could not serialize dictionary to data")
            return false
        }
        
        do {
            try appData.write(to: writeUrl)
            
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func deleteUserData(user: String) -> Bool {
        let fileManager = FileManager.default
        let fileName = "\(user)-\(baseFileName)"
        
        guard let documentsDirectory = documentsUrl else {
            print("Could not read documents directory")
            return false
        }
        
        let appDataUrlPath = documentsDirectory.appendingPathComponent(fileName, isDirectory: false).path
        
        guard fileManager.fileExists(atPath: appDataUrlPath) else {
            print("No saved data")
            return false
        }
        
        do {
            try fileManager.removeItem(atPath: fileName)
            return true
        }
        catch {
            print(error.localizedDescription)
            return false
        }
    }
}
