import UIKit
import KingPastaKit

class DayController: UITableViewController {
    
    var day: Day!
    var periods = [Period]()
    
    var needsReload = false
    var showPeriod: Period?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = day.name
        periods = Array(day.orderedPeriods())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setToolbarHidden(false, animated: animated)
        
        if needsReload {
            periods = Array(day.orderedPeriods())
            tableView.reloadData()
            needsReload = false
        }
        
        updateHintImageView()
        
        if let period = showPeriod, let row = periods.indexOf({ $0 == period }) {
            let indexPath = NSIndexPath(forRow: row, inSection: 3)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
            showPeriod = nil
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        updateHintImageView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "EditPeriodSegue":
                if let periodVC = segue.destinationViewController as? PeriodController, let indexPath = tableView.indexPathForSelectedRow {
                    periodVC.period = periods[indexPath.row]
                }
            case "AddPeriodSegue":
                (segue.destinationViewController as? PeriodController)?.day = day
            default:
                break
            }
        }
        
        needsReload = true
    }
    
    func save() {
        view.endEditing(true)    // this might need to be called on back too (somehow!)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func updateHintImageView() {
        if periods.count < 1 && (UIDevice.currentDevice().orientation == .Portrait || UIScreen.mainScreen().bounds.size.height == 736 || UIScreen.mainScreen().bounds.size.height == 414) {
            let hintImageView = UIImageView(image: UIImage(named: "periods_hint"))
            hintImageView.contentMode = .Bottom
            tableView.backgroundView = hintImageView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    @IBAction func showPeriodFromSegue(segue: UIStoryboardSegue) {
        // TODO: Implement this!
        // if let segue.sourceViewController.new_period
        // showPeriod = segue.sourceViewController.period
    }
    
    @IBAction func notificationsSwitchDidChange(sender: UISwitch) {
        try! FkP.realm.write() {
            self.day.showsNotifications = sender.on
        }
        
        if sender.on { AppDelegate.registerNotifications() }
    }
    
    func showClearConfirmation() {
        let confirmSheet = UIAlertController(title: "Delete \(day.name)?", message: "Do you really want to delete this schedule?", preferredStyle: .ActionSheet)
        confirmSheet.addAction(UIAlertAction(title: "Delete", style: .Destructive) { action in
            self.clearPeriods()
        })
        confirmSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(confirmSheet, animated: true, completion: nil)
    }
    
    func clearPeriods() {
        try! FkP.realm.write {
            for period in self.day.periods { FkP.realm.delete(period) }
        }
        
        periods = Array(day.orderedPeriods())
        tableView.reloadData()
    }
    
}

// MARK: UITableViewDataSource
extension DayController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return periods.count > 0 ? 3 : 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return periods.count
        case 2:
            return 1
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as? NotificationsCell ?? NotificationsCell(style: .Default, reuseIdentifier: "NotificationsCell")
            cell.notificationsSwitch.on = day.showsNotifications
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("PeriodCell") as? PeriodCell ?? PeriodCell(style: .Default, reuseIdentifier: "PeriodCell")
            
            let period = periods[indexPath.row]
            
            cell.categoryColorMark.color = period.category?.color
            cell.periodNameLabel.text = period.name
            cell.timeRangeLabel.text = "\(period.startTime.shortString) - \(period.endTime.shortString)"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("ClearDayCell") ?? UITableViewCell(style: .Default , reuseIdentifier: "ClearDayCell")
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1 ? true : false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if editingStyle == .Delete {
                let deletedPeriod = periods.removeAtIndex(indexPath.row)
                try! FkP.realm.write {
                    FkP.realm.delete(deletedPeriod)
                }
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            updateHintImageView()
        }
    }
}

// MARK UITableViewDelegate
extension DayController {
    
    // TODO: Implement in storyboard? How about deselecting?
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            showClearConfirmation()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
}