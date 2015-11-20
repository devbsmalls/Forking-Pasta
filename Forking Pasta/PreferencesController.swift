import UIKit

class PreferencesController: UITableViewController {
    
    private var needsReload = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsReload {
            tableView.reloadData()
            needsReload = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier, let selectedIndexPath = tableView.indexPathForSelectedRow {
            if identifier == "EditCategorySegue" {
                needsReload = true
                (segue.destinationViewController as? EditCategoryController)?.category = Category.forIndex(selectedIndexPath.row)
            }
        }
    }
    
    func done() {
        navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func timeIntervalDidChange(sender: UISegmentedControl) {
        FkP.useFiveMinuteIntervals = sender.selectedSegmentIndex == 1
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return Category.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return "Categories"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TimePickerIntervalCell") as? TimePickerIntervalCell ?? TimePickerIntervalCell(style: .Default, reuseIdentifier: "TimePickerIntervalCell")
            if FkP.useFiveMinuteIntervals == false { cell.timeIntervalControl.selectedSegmentIndex = 0 }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell") as? SelectCategoryCell ?? SelectCategoryCell(style: .Default, reuseIdentifier: "CategoryCell")
            let category = Category.forIndex(indexPath.row)
            cell.nameLabel.text = category.name
            cell.colorMark.color = category.color
            
            return cell
        }
    }
    
}