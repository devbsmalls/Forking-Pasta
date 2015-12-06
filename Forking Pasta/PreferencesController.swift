import UIKit
import KingPastaKit

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
            if identifier == "EditTimeZoneSegue" {
                needsReload = true
                (segue.destinationViewController as? EditTimeZoneController)?.timeZone = TimeZone.forIndex(selectedIndexPath.row)
            }
        }
    }
    
    func done() {
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.syncToWatch()
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
            return TimeZone.count
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
            let cell = tableView.dequeueReusableCellWithIdentifier("TimeZoneCell") as? SelectTimeZoneCell ?? SelectTimeZoneCell(style: .Default, reuseIdentifier: "TimeZoneCell")
            let timeZone = TimeZone.forIndex(indexPath.row)
            cell.nameLabel.text = timeZone.name
            cell.colorMark.color = timeZone.color
            
            return cell
        }
    }
    
}