import UIKit
import KingPastaKit

class EditCategoryController: UITableViewController {
    
    var category: KPCategory!
    
    private var colors = KPCategory.colors
    private var categoryName: String?
    private var categoryColorIndex: Int?
    private var selectedIndexPath: NSIndexPath?
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryName = category.name
        categoryColorIndex = category.colorIndex
    }
    
    func save() {
        view.endEditing(true)
        
        try! FkP.realm.write {
            self.category.name = self.categoryName ?? ""
            self.category.colorIndex = self.categoryColorIndex ?? 0
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func cancel() {
        // do nothing, edited variables will simply be deleted
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nameDidChange(sender: UITextField) {
        categoryName = sender.text
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
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryNameCell") as? CategoryNameCell ?? CategoryNameCell(style: .Default, reuseIdentifier: "CategoryNameCell")
            cell.nameTextField.delegate = self
            cell.nameTextField.text = categoryName
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryColorCell") as? CategoryColorCell ?? CategoryColorCell(style: .Default, reuseIdentifier: "CategoryColorCell")
            
            let color = colors[indexPath.row]
            if categoryColorIndex == indexPath.row {
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
            
            categoryColorIndex = indexPath.row
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            selectedIndexPath = indexPath
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}

// MARK: UITextFieldDelegate
extension EditCategoryController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
