import UIKit

class ScheduleController: UITableViewController {
    var schedules = Array(FkP.realm.objects(Schedule).sorted("name"))
    var needsReload = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setToolbarHidden(false, animated: animated)
        
        if needsReload {
            schedules = Array(FkP.realm.objects(Schedule).sorted("name"))
            tableView.reloadData()
            needsReload = false
        }
        
        updateHintImageView()   // after reload check to ensure correct number of periods
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !FkP.hasSeenGettingStarted { showGettingStarted() }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "WakeTimeSegue":
                segue.destinationViewController.isWake = true
            case "BedTimeSegue":
                segue.destinationViewController.isWake = false
            case "EditScheduleSegue":
                let indexPath = tableView.indexPathForSelectedRow
                segue.destinationViewController.schedule = schedules[indexPath.row]
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
    
    func updateHintImageView() {
        if schedules.count > 1 {
            let hintImageView = UIImageView(image: UIImage(named: "schedules_hint"))
            hintImageView.contentMode = .Bottom
            tableView.backgroundView = hintImageView
        } else {
            tableView.backgroundView = nil
        }
    }
}

// MARK: UITableViewDataSource
extension ScheduleController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return schedules.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("WakeTimeCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "WakeTimeCell")
                cell.detailTextLabel?.text = FkP.wakeTime.utc.strftime("%H:%M")
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("BedTimeCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "BedTimeCell")
                cell.detailTextLabel?.text = FkP.bedTime.utc.strftime("%H:%M")
                
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "ScheduleCell")
            let schedule = schedules[indexPath.row]
            
            if schedule.name == "" {
                cell.textLabel?.text = "Unnamed Schedule"
            } else {
                cell.textLabel?.text = schedule.name
            }
            
            cell.detailTextLabel?.text = schedule.daysString
            
            cell
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row == 1 ? true : false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let deletedSchedule = schedules.removeAtIndex(indexPath.row)
            for d in deletedSchedule.days { d.schedule = nil }      // TODO: Is this needed??
            
            // TODO: Refactor?
            try! FkP.realm.write {
                FkP.realm.delete(deletedSchedule)
            }
            
            if editingStyle == .Delete {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            updateHintImageView()
        }
    }
}