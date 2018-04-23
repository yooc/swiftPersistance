import Foundation

protocol PersistenceModelDelegate: class {
    func dataSaved()
    func errorSaving()
    func reloadData()
}

class PersistenceModel {
    private let currentUserKey = "currentUser"
    
    private let persistence = Persistence()
    private let settingsDefaults = SettingDefaults()
    
    var availableUsers = [String]()
    private(set) var currentUser: String
    
    var lastRequestToSave: DispatchWorkItem?
    
    weak var persistenceModelDelegate: PersistenceModelDelegate?
    
    init() {
        currentUser =  settingsDefaults.valueFor(key: currentUserKey) ?? ""
    }
    
    func setAvailableUsers() {
        let jsonData = persistence.readAvailableUsers()
        
        guard let userData = jsonData?["Current Available Users"] else {
            print("Unable to get available users")
            return
        }
        
        availableUsers = userData as! [String]
    }
    
    func saveAvailableUsers() {
        lastRequestToSave?.cancel()
        
        let saveChangesWorkItem = DispatchWorkItem { [weak self] in
            
            guard let currentAvailableUsers = self?.availableUsers else { return }
            
            let userStrings = currentAvailableUsers
            
            let result = self?.persistence.writeAvailableUsers(appDataDictionary: ["Current Available Users": userStrings]) ?? false
            
            result ? self?.persistenceModelDelegate?.dataSaved() : self?.persistenceModelDelegate?.errorSaving()
        }
        
        lastRequestToSave = saveChangesWorkItem
        
        let _ = saveChangesWorkItem.wait(timeout: .now() + 2)
        
        saveChangesWorkItem.perform()
        
        setAvailableUsers()
    }
    
    func saveUserText(text: String) {
        lastRequestToSave?.cancel()
        
        let saveChangesWorkItem = DispatchWorkItem { [weak self] in
            let appDataDictionary = ["noteText": text]
            
            guard let currentUser = self?.currentUser else { return }
            
            let result = self?.persistence.writeUserData(appDataDictionary: appDataDictionary, user: currentUser) ?? false
            
            result ? self?.persistenceModelDelegate?.dataSaved() : self?.persistenceModelDelegate?.errorSaving()
        }
        
        lastRequestToSave = saveChangesWorkItem
        
        let _ = saveChangesWorkItem.wait(timeout: .now() + 2)
        
        saveChangesWorkItem.perform()
    }
    
    var persistedText: String? {
        return persistence.readUserData(for: currentUser)?["noteText"] as? String
    }
}

extension PersistenceModel: SettingsDelegate {
    func selected(user: String) {
        settingsDefaults.add(value: user, forKey: currentUserKey)
        currentUser = user
        persistenceModelDelegate?.reloadData()
    }
    
    func addNewUser(user: String) {
        availableUsers.append(user)
    }
    
    func deleteUser(user: String) {
        if persistence.deleteUserData(user: user) {
            guard let indexToRemove = availableUsers.index(of: user) else { return }
            availableUsers.remove(at: indexToRemove)
            
            saveAvailableUsers()
        } else {
            print("Unable to delete user")
        }
    }
}
