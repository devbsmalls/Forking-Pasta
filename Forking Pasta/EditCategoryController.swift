import UIKit
import KingPastaKit

class EditTimeZoneController: UITableViewController {
    
    var timeZone: TimeZone!
    
    private var colors = TimeZone.colors
    private var timeZoneName: String?
    private var timeZoneColorIndex: Int?
    private var selectedIndexPath: NSIndexPath?
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeZoneName = timeZone.name
        timeZoneColorIndex = timeZone.colorIndex
    }
    
    func save() {
        view.endEditing(true)
        
        try! FkP.realm.write {
            self.timeZone.name = self.timeZoneName ?? ""
            self.timeZone.colorIndex = self.timeZoneColorIndex ?? 0
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func cancel() {
        // do nothing, edited variables will simply be deleted
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nameDidChange(sender: UITextField) {
        timeZoneName = sender.text
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return colors.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TimeZoneNameCell") as? TimeZoneNameCell ?? TimeZoneNameCell(style: .Default, reuseIdentifier: "TimeZoneNameCell")
            cell.nameTextField.delegate = self
            cell.nameTextField.text = timeZoneName
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TimeZoneColorCell") as? TimeZoneColorCell ?? TimeZoneColorCell(style: .Default, reuseIdentifier: "TimeZoneColorCell")
            
            let color = colors[indexPath.row]
            if timeZoneColorIndex == indexPath.row {
                cell.accessoryType = .Checkmark
                selectedIndexPath = indexPath
            }
            
            cell.colorNameLabel.text = String(color)    // Swift returns enum value's name as a string
            cell.colorMark.color = color.value
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if let selectedIndexPath = selectedIndexPath {
                tableView.cellForRowAtIndexPath(selectedIndexPath)?.accessoryType = .None
            }
            
            timeZoneColorIndex = indexPath.row
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            selectedIndexPath = indexPath
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}

// MARK: UITextFieldDelegate
extension EditTimeZoneController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
