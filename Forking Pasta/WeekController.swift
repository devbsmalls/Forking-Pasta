import UIKit

class WeekController: UITableViewController {
    var days = Array(FkP.realm.objects(Day).sorted("dayOfWeek"))
    var needsReload = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsReload {
            days = Array(FkP.realm.objects(Day).sorted("dayOfWeek"))
            tableView.reloadData()
            needsReload = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !FkP.hasSeenGettingStarted { showGettingStarted() }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "WakeTimeSegue":
                (segue.destinationViewController as? WakeBedTimeController)?.isWake = true
            case "BedTimeSegue":
                (segue.destinationViewController as? WakeBedTimeController)?.isWake = false
            case "DaySegue":
                let indexPath = tableView.indexPathForSelectedRow
                (segue.destinationViewController as? DayController)?.day = days[indexPath!.row]
            default:
                break
            }
        }
        
        needsReload = true
    }
    
    func showGettingStarted() {
        if let gettingStarted = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughController") as? WalkthroughController {
            gettingStarted.backgroundImage = UIImage(named: "getting_started_background")
            presentViewController(gettingStarted, animated: true, completion: nil)
            
            FkP.hasSeenGettingStarted = true
        }
    }
    
    @IBAction func done() {
        FkP.scheduleNotifications()
        navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: UITableViewDataSource
extension WeekController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return days.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("WakeTimeCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "WakeTimeCell")
                cell.detailTextLabel?.text = FkP.wakeTime.shortString
                
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("BedTimeCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "BedTimeCell")
                cell.detailTextLabel?.text = FkP.bedTime.shortString
                
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("DayCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "Day Cell")
            
            let day = days[indexPath.row]
            cell.textLabel?.text = day.name
            
            return cell
        }
    }

}