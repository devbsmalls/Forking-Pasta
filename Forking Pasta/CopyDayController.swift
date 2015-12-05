import UIKit
import KingPastaKit

class CopyDayController: UITableViewController {
    
    var day: Day!
    var days: [Day]!
    var daysEnabled: [Bool]!
    
    
    override func viewDidLoad() {
        days = Array(FkP.realm.objects(Day).sorted("dayOfWeek"))
        daysEnabled = [Bool](count: days.count, repeatedValue: false)
    }
    
    @IBAction func done() {
        let confirmSheet = UIAlertController(title: "Warning", message: "This action will erase any existing periods during the selected days. Do you wish to continue?", preferredStyle: .ActionSheet)
        confirmSheet.addAction(UIAlertAction(title: "Yes", style: .Destructive) { action in
            self.copyPeriods()
        })
        confirmSheet.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        presentViewController(confirmSheet, animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func copyPeriods() {
        let realm = FkP.realm
        
        for destinationDay in days {
            if daysEnabled[destinationDay.dayOfWeek] {
                destinationDay.clear()
                
                for period in day.periods {
                    let copy = Period()
                    copy.name = period.name
                    copy.startTime = period.startTime
                    copy.endTime = period.endTime
                    copy.day = destinationDay
                    copy.category = period.category
                    
                    try! realm.write { realm.add(copy) }
                }
                
                try! realm.write { destinationDay.showsNotifications = self.day.showsNotifications }
            }
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CopyDayCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "CopyDayCell")
        cell.textLabel?.text = days[indexPath.row].name
        
        let isDestinationDay = (days[indexPath.row] != day)
        cell.userInteractionEnabled = isDestinationDay
        cell.textLabel?.enabled = isDestinationDay
        cell.accessoryType = daysEnabled[indexPath.row] ? .Checkmark : .None
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        daysEnabled[indexPath.row] = !daysEnabled[indexPath.row]
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}