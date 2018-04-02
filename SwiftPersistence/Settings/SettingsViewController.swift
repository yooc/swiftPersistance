import UIKit

protocol SettingsDelegate: class {
    func selected(user: User)
}

class SettingsViewController: UIViewController {
    weak var settingsDelegate: SettingsDelegate?
    
    @IBAction func user1Pressed(_ sender: UIButton)     {
        settingsDelegate?.selected(user: .user1)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func user2Pressed(_ sender: UIButton) {
        settingsDelegate?.selected(user: .user2)
        dismiss(animated: true, completion: nil)
    }
}
