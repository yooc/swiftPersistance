import UIKit

class ViewController: UIViewController {
    let persistenceModel = PersistenceModel()
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveStatusLabel: UILabel!
    @IBOutlet weak var currentUserLabel: UILabel!
    
    @IBAction func deleteUserButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Really delete user \(persistenceModel.currentUser)?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.persistenceModel.deleteUser(user: self.persistenceModel.currentUser)
        }))
        
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        persistenceModel.persistenceModelDelegate = self
        noteTextView.delegate = self
        noteTextView.text = persistenceModel.persistedText
        currentUserLabel.text = persistenceModel.currentUser
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settingsViewController = segue.destination as? SettingsViewController else { return }
        
        settingsViewController.settingsDelegate = persistenceModel
        settingsViewController.model = persistenceModel
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        saveStatusLabel.text = "Unsaved changes..."
        DispatchQueue.global().async {
            self.persistenceModel.saveUserText(text: textView.text)
        }
    }
}

extension ViewController: PersistenceModelDelegate {
    func dataSaved() {
        DispatchQueue.main.async { [weak self] in
            self?.saveStatusLabel.text = "Saved changes"
        }
    }
    
    func errorSaving() {
        let alert = UIAlertController(title: "Error Saving", message: "We couldn't save your note as this time", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func reloadData() {
        noteTextView.text = persistenceModel.persistedText
        currentUserLabel.text = persistenceModel.currentUser
        saveStatusLabel.text = "No changes"
    }
}
