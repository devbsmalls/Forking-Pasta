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
            let indexPath = NSIndexPath(forRow: row, inSection: 1)
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
            case "CopyDaySegue":
                (segue.destinationViewController as? CopyDayController)?.day = day
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
        if let periodVC = segue.sourceViewController as? PeriodController where periodVC.isNewPeriod {
            showPeriod = periodVC.period
        }
    }
    
    @IBAction func notificationsSwitchDidChange(sender: UISwitch) {
        try! FkP.realm.write { self.day.showsNotifications = sender.on }
        
        if sender.on { AppDelegate.registerNotifications() }
    }
    
    @IBAction func showClearConfirmation(sender: UIBarButtonItem) {
        let confirmSheet = UIAlertController(title: "Clear \(day.name)?", message: "This will delete all periods in this schedule. Are you sure?", preferredStyle: .ActionSheet)
        confirmSheet.addAction(UIAlertAction(title: "Clear", style: .Destructive) { action in
            self.clearPeriods()
        })
        confirmSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(confirmSheet, animated: true, completion: nil)
    }
    
    func clearPeriods() {
        day.clear()
        
        periods = Array(day.orderedPeriods())
        tableView.reloadData()
    }
    
}

// MARK: UITableViewDataSource
extension DayController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return periods.count
        }

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
            
            cell.colorMark.color = period.timeZone?.color
            cell.periodNameLabel.text = period.name
            cell.timeRangeLabel?.monospaceDigits()
            cell.timeRangeLabel.text = "\(period.startTime.shortString) - \(period.endTime.shortString)"
            
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
                let realm = FkP.realm
                
                let deletedPeriod = periods.removeAtIndex(indexPath.row)
                try! realm.write { realm.delete(deletedPeriod) }
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            updateHintImageView()
        }
    }
}
