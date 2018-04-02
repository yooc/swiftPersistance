import Foundation

protocol PersistenceModelDelegate: class {
    func dataSaved()
    func errorSaving()
    func reloadData()
}

enum User: String {
    case user1 = "user1"
    case user2 = "user2"
}

class PersistenceModel {
    private let currentUserKey = "currentUser"
    
    private let persistence = Persistence()
    private let settingsDefaults = SettingDefaults()
    private var currentUser: User
    
    var lastRequestToSave: DispatchWorkItem?
    
    weak var persistenceModelDelegate: PersistenceModelDelegate?
    
    init() {
        currentUser =  User(rawValue: settingsDefaults.valueFor(key: currentUserKey) ?? "") ?? .user1
    }
    
    func save(text: String) {
        lastRequestToSave?.cancel()
        
        let saveChangesWorkItem = DispatchWorkItem { [weak self] in
            let appDataDictionary = ["noteText": text]
            
            guard let currentUser = self?.currentUser.rawValue else { return }
            
            let result = self?.persistence.write(appDataDictionary: appDataDictionary, user: currentUser) ?? false
        
            result ? self?.persistenceModelDelegate?.dataSaved() : self?.persistenceModelDelegate?.errorSaving()
        }
        
        lastRequestToSave = saveChangesWorkItem
        
        let _ = saveChangesWorkItem.wait(timeout: .now() + 2)
        
        saveChangesWorkItem.perform()
    }
    
    var persistedText: String? {
        return persistence.read(for: currentUser.rawValue)?["noteText"] as? String
    }
}

extension PersistenceModel: SettingsDelegate {
    func selected(user: User) {
        settingsDefaults.add(value: user.rawValue, forKey: currentUserKey)
        currentUser = user
        persistenceModelDelegate?.reloadData()
    }
}
