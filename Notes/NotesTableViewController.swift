import UIKit

struct Notes {
    var notes: String
    var time: String
    var data: String
    var timeData: String
}

// класс первого экрана
class NotesTableViewController: UITableViewController, NoteDelegate, UIActionSheetDelegate, EditDelegate {
    
    // для поиска
    let searchController = UISearchController(searchResultsController: nil)
    var filteredNotes = [Notes]()
    
    // подача текста для нотатки
    var notes = [Notes]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.newBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        // для поиска
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        let note = notes
        filteredNotes = note.filter({( note : Notes) -> Bool in
            return note.notes.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // возврат количества ячеек в таблице
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredNotes.count
        }
        let note = notes
        return note.count
    }
    
    // возврат что именно в ячейке
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        
        var note: Notes
        if isFiltering() {
            note = filteredNotes[indexPath.row]
        } else {
            note = notes[indexPath.row]
        }
        cell.setup(with: note)
        return cell
    }
    
    // переход на другие окна
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetail" {
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }
            let note = notes[indexPath.row]
            if let detailVC: DetailVC = segue.destination as? DetailVC {
                detailVC.moreNote = note
            }
        } else if segue.identifier == "newNote" {
            let addNewNote = segue.destination as? AddNewNote
            addNewNote?.delegate = self
        }
        else  if segue.identifier == "editNotes" {
            guard let indexPath = sender as? Int else { return }
            let note = notes[indexPath]
            
            if let editNotes:  EditViewController = segue.destination as? EditViewController {
                editNotes.editNotes = note
                editNotes.delegate = self
                tableView.reloadData()
            }
        }
    }
    
    // добавление новой нотатки
    func noteInformation(with newNotesInform: Notes) {
        notes.append(newNotesInform)
        self.tableView.reloadData()
    }
    
    // обновить нотатку
    func editNote (with editNotesNew: Notes){
        notes.append(editNotesNew)
        print(editNotesNew)
        self.tableView.reloadData()
    }
    
    // удалить и редактировать нотатку
    // для создания кнопок удаления и редактирования
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let note = notes[indexPath.row]
        let editAction = UITableViewRowAction(style: .default, title: "Изменить") { (action, indexPath) in
            self.updateAction(note: note , indexPath: indexPath)
            
            self.performSegue(withIdentifier: "editNotes", sender: indexPath.row)
        }
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
            self.deleteAction(note: note , indexPath: indexPath)
        }
        deleteAction.backgroundColor = .red
        editAction.backgroundColor = .blue
        return [deleteAction, editAction]
    }
    
    // кнопка для обновления
    private func updateAction(note:Notes, indexPath: IndexPath) {
        
    }
    
    // кнопка для удаления
    private func deleteAction(note: Notes, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Удалить", message: "Вы уверены, что хотите удалить?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Да", style: .default) { (action) in
            self.notes.remove(at: indexPath.row)
            self.tableView?.deleteRows(at: [indexPath], with: .automatic)
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    // для сортирования ячеек
    @IBAction func sortButton(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: "По алфавиту", style: .default) { action -> Void in
            print("First Action pressed")
            self.notes.sort(by: { $0.notes < $1.notes })
            self.tableView.reloadData()
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "От новых к старым", style: .default) { action -> Void in
            print("Second Action pressed")
            self.notes.sort(by: { $0.timeData > $1.timeData })
            self.tableView.reloadData()
        }
        
        let thirdAction: UIAlertAction = UIAlertAction(title: "От старых к новым", style: .default) { action -> Void in
            print("Third Action pressed")
            self.notes.sort(by: { $0.timeData < $1.timeData })
            self.tableView.reloadData()
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Отмена", style: .cancel) { action -> Void in }
        
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(thirdAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
}

// для поиска
extension NotesTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
}

// класс окна для детальной нотатки
class DetailVC: UIViewController {
    
    @IBOutlet weak var allTextNote: UITextView!
    var moreNote: Notes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allTextNote.textColor = UIColor.black
        allTextNote.text = moreNote?.notes
        
        navigationController?.navigationBar.barTintColor = UIColor.newBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    // чтобы отправить нотатку другому человеку с кнопкой
    @IBAction func shareTextButton(_ sender: Any) {
        
        let textToShare = [ allTextNote ]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToFacebook  ]
        self.present(activityViewController, animated: true, completion: nil)
    }
}

protocol EditDelegate: class {
    func editNote (with editNotesNew: Notes)
}

class EditViewController: UIViewController {
    
    var editNotes: Notes?
    weak var delegate: EditDelegate? = nil
    
    @IBOutlet weak var textNotes: UITextView!
    @IBAction func editButton(_ sender: Any) {
        
        let newTimeData = DateFormatter()
        newTimeData.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = newTimeData.string(from: Date())
        let newData = newTimeData.date(from: myString)
        newTimeData.dateFormat = "dd.MM.yy"
        let myStringafd = newTimeData.string(from: newData!)
        newTimeData.dateFormat = "HH:mm"
        let myStringTime = newTimeData.string(from: newData!)
        newTimeData.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myStringDataTime = newTimeData.string(from: newData!)
        
        let editNotesNew = Notes(notes: textNotes.text, time: myStringTime, data: myStringafd, timeData: myStringDataTime)
        delegate?.editNote(with: editNotesNew)
        _ = self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textNotes.text = editNotes?.notes
    }
}
