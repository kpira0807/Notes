import UIKit

protocol NoteDelegate: class {
    func noteInformation(with newNotesInform: Notes)
}
// класс для окна с добавлением нотатки
class AddNewNote: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.newBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    weak var delegate: NoteDelegate? = nil
    @IBOutlet weak var newNoteText: UITextView!
    @IBAction func saveButton(_ sender: Any) {
        
        guard let newNoteText = newNoteText.text,
            !newNoteText.isEmpty
            else {
                AlertError(with: ErrorMessege.emptyNote)
                return
        }
        let newTimeData = DateFormatter()
        print(newTimeData)
        newTimeData.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = newTimeData.string(from: Date())
        let newData = newTimeData.date(from: myString)
        newTimeData.dateFormat = "dd.MM.yy"
        let myStringafd = newTimeData.string(from: newData!)
        newTimeData.dateFormat = "HH:mm"
        let myStringTime = newTimeData.string(from: newData!)
        newTimeData.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myStringDataTime = newTimeData.string(from: newData!)
        
        
        let newNotesInform = Notes(notes: newNoteText, time: myStringTime, data: myStringafd, timeData: myStringDataTime)
        delegate?.noteInformation(with: newNotesInform)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func AlertError(with type: ErrorMessege) {
        let myAlert = UIAlertController(title: "Ошибка", message: type.rawValue, preferredStyle: .alert)
        let okeyAction = UIAlertAction(title: "Окей", style: .default, handler: nil)
        myAlert.addAction(okeyAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}

