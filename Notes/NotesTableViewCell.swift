import UIKit

// расширение для того чтоб потом можно было ограничить вывод заметки в первом экране до 100 символов
extension String {
    func maxLength(length: Int) -> String {
        var str = self
        let nsString = str as NSString
        if nsString.length >= length {
            str = nsString.substring(with:
                NSRange(
                    location: 0,
                    length: nsString.length > length ? length : nsString.length)
            )
        }
        return  str
    }
}

class NotesTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateLabel.textColor = UIColor.lightGray
        timeLabel.textColor = UIColor.lightGray
        informationLabel.textColor = UIColor.black
    }
    
    func setup(with note: Notes) {
        if note.notes.count > 100 {
            informationLabel.text = note.notes.maxLength(length: 100) + "..."
        } else {
            informationLabel.text = note.notes
        }
        dateLabel.text = note.data
        timeLabel.text = note.time
    }
}
