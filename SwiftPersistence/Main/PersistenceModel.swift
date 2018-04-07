import Foundation

protocol PersistenceModelDelegate: class {
    func dataSaved()
    func errorSaving()
    func reloadData()
}

struct UserObject {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

class PersistenceModel {
    private let currentUserKey = "currentUser"
    
    private let persistence = Persistence()
    private let settingsDefaults = SettingDefaults()
    
    var availableUsers = [UserObject]()
    private(set) var currentUser: UserObject
    
    var lastRequestToSave: DispatchWorkItem?
    
    weak var persistenceModelDelegate: PersistenceModelDelegate?
    
    init() {
        currentUser =  UserObject(name: settingsDefaults.valueFor(key: currentUserKey) ?? "")
    }
    
    func save(text: String) {
        lastRequestToSave?.cancel()
        
        let saveChangesWorkItem = DispatchWorkItem { [weak self] in
            let appDataDictionary = ["noteText": text]
            
            guard let currentUser = self?.currentUser.name else { return }
            
            let result = self?.persistence.write(appDataDictionary: appDataDictionary, user: currentUser) ?? false
        
            result ? self?.persistenceModelDelegate?.dataSaved() : self?.persistenceModelDelegate?.errorSaving()
        }
        
        lastRequestToSave = saveChangesWorkItem
        
        let _ = saveChangesWorkItem.wait(timeout: .now() + 2)
        
        saveChangesWorkItem.perform()
    }
    
    var persistedText: String? {
        return persistence.read(for: currentUser.name)?["noteText"] as? String
    }
}

extension PersistenceModel: SettingsDelegate {
    func selected(user: UserObject) {
        settingsDefaults.add(value: user.name, forKey: currentUserKey)
        currentUser = user
        persistenceModelDelegate?.reloadData()
    }
    
    func addNewUser(user: UserObject) {
        availableUsers.append(user)
    }
    
    func deleteUser(index: Int) {
        availableUsers.remove(at: index)
    }
}
