import UIKit

protocol SettingsDelegate: class {
    func selected(user: UserObject)
    func addNewUser(user: UserObject)
    func deleteUser(index: Int)
}

class SettingsViewController: UIViewController {
    var model: PersistenceModel?
    
    @IBOutlet weak var usersTableView: UITableView!
    
    weak var settingsDelegate: SettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersTableView.dataSource = self
    }
    
    @IBAction func addUserAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Enter user name", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input your name here..."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let name = alert.textFields?.first?.text {
                let userToAdd = UserObject.init(name: name)
                self.model?.addNewUser(user: userToAdd)
            }
        }))
        
        self.present(alert, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.availableUsers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = usersTableView.dequeueReusableCell(withIdentifier: "userCell") else { return UITableViewCell() }
        
        let userName = model?.availableUsers.element(at: indexPath.row)?.name ?? "Unable to get userName"
        
        cell.textLabel?.text = userName
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = model?.availableUsers.element(at: indexPath.row)?.name ?? "Unable to get selected user"
        let alert = UIAlertController(title: "Really delete user \(selectedUser)", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
                self.model?.deleteUser(index: indexPath.row)
        }))
        
        self.present(alert, animated: true)
    }
}
