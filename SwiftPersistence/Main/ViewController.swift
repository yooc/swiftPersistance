import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveStatusLabel: UILabel!
    
    let persistenceModel = PersistenceModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        persistenceModel.persistenceModelDelegate = self
        noteTextView.delegate = self
        noteTextView.text = persistenceModel.persistedText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settingsViewController = segue.destination as? SettingsViewController else { return }
        
        settingsViewController.settingsDelegate = persistenceModel
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        saveStatusLabel.text = "Unsaved changes..."
        DispatchQueue.global().async {
            self.persistenceModel.save(text: textView.text)
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
        saveStatusLabel.text = "No changes"
    }
}
