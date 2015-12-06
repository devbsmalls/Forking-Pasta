import UIKit
import KingPastaKit

class PeriodController: UITableViewController {
    
    var day: Day?
    var period: Period?
    var isNewPeriod = false
    
    var periodName: String?
    var periodTimeZone: TimeZone?
    var periodStartTime: NSTimeInterval?
    var periodEndTime: NSTimeInterval?
    var periodDay: Day?
    
    private var needsReload = false

    // TODO: Maybe should error some how if no day is passed in??
    
    private var warningCellType: Period.OverlapType?
    private let normalTextColor = UITableViewCell(style: .Value1, reuseIdentifier: "").detailTextLabel!.textColor
    private let warningTextColor = UIColor(hue: 359/360.0, saturation: 0.75, brightness: 1.0, alpha: 1.0)
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let period = period {
            navigationItem.title = "Edit Period"
            
            periodName = period.name
            periodTimeZone = period.timeZone
            periodStartTime = period.startTime
            periodEndTime = period.endTime
            periodDay = period.day
        } else {
            isNewPeriod = true
            periodDay = day
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsReload {
            tableView.reloadData()
            needsReload = false
        }
        
        validate()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "SelectTimeZoneSegue":
                if let timeZoneVC = segue.destinationViewController as? SelectTimeZoneController {
                    timeZoneVC.delegate = self
                    timeZoneVC.periodTimeZone = periodTimeZone
                }
            case "SetStartTimeSegue":
                if let timeVC = segue.destinationViewController as? SetTimeController {
                    timeVC.delegate = self
                    timeVC.periodStartTime = periodStartTime
                    timeVC.periodEndTime = periodEndTime
                    timeVC.periodDay = periodDay
                    timeVC.isStart = true
                }
            case "SetEndTimeSegue":
                if let timeVC = segue.destinationViewController as? SetTimeController {
                    timeVC.delegate = self
                    timeVC.periodStartTime = periodStartTime
                    timeVC.periodEndTime = periodEndTime
                    timeVC.periodDay = periodDay
                    timeVC.isStart = false
                }
            case "SaveUnwind":
                let realm = FkP.realm
                view.endEditing(true)
                
                if isNewPeriod {
                    let periodDictionary: [String: AnyObject] = [
                        "name": periodName!,
                        "timeZone": periodTimeZone!,
                        "startTime": periodStartTime!,
                        "endTime": periodEndTime!,
                        "day": periodDay!
                    ]
                    let newPeriod = Period(value: periodDictionary)
                    try! realm.write { realm.add(newPeriod) }
                } else if let period = period {
                    try! realm.write {
                        period.name = self.periodName!
                        period.timeZone = self.periodTimeZone
                        period.startTime = self.periodStartTime!
                        period.endTime = self.periodEndTime!
                        period.day = self.periodDay
                    }
                }
            default:
                break
            }
        }
        
        needsReload = true
    }
    
    func validate() {
        var valid = true
        if periodName == nil || periodName == "" { valid = false }
        if periodTimeZone == nil { valid = false }      // TODO: or not == existing timeZone
        if let periodStartTime = periodStartTime, let periodEndTime = periodEndTime {
            if periodEndTime == periodStartTime {
                valid = false
                showTimeWarningOfType(.StartsAtEnd)
            } else if periodEndTime < periodStartTime {
                valid = false
                showTimeWarningOfType(.StartsAfterEnd)
            } else if Period.overlapWithStartTime(periodStartTime, endTime: periodEndTime, day: periodDay, ignoringPeriod: period) {    // FIXME: Sort out optionals
                valid = false
                showTimeWarningOfType(.Overlap)
            } else {
                hideTimeWarning()
            }
        } else {
            valid = false
        }
        
        saveButton.enabled = valid
    }
    
    @IBAction func cancel() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nameDidChange(sender: UITextField) {
        periodName = sender.text ?? ""
        validate()
    }
    
    func hideKeyboard() {
        // scrollview keyboard: “Dismiss on drag”.
        // gesture recognizer cancelsTouchesInView = false
        view.endEditing(true)
    }
    
    func showTimeWarningOfType(type: Period.OverlapType) {
        if warningCellType != type {
            warningCellType = type
            tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
            // TODO: remove?? tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 2)], withRowAnimation: .Fade)
        }
    }
    
    func hideTimeWarning() {
        if warningCellType != nil {
            warningCellType = nil
            tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
        }
    }
    
    func showDeleteConfirmation() {
        view.endEditing(true)       // ensure any changes are merged into period before deleting
        
        let confirmSheet = UIAlertController(title: "Delete \(periodName)?", message: "Do you really want to delete this period?", preferredStyle: .ActionSheet)
        confirmSheet.addAction(UIAlertAction(title: "Delete", style: .Destructive) { action in
            self.deletePeriod()
        })
        confirmSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(confirmSheet, animated: true, completion: nil)
    }
    
    func deletePeriod() {
        let realm = FkP.realm
        try! realm.write { realm.delete(self.period!) }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
}

// MARK: UITextFieldDelegate
extension PeriodController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

// MARK: UITableViewDataSource
extension PeriodController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return isNewPeriod ? 3 : 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0...1:
            return 1
        case 2:
            return warningCellType == nil ? 2 : 3
        case 3:
            return 1
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("PeriodNameCell") as? PeriodNameCell ?? PeriodNameCell(style: .Default, reuseIdentifier: "PeriodNameCell")
            cell.nameTextField.delegate = self
            cell.nameTextField.text = periodName
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("PeriodTimeZoneCell") as? PeriodTimeZoneCell ?? PeriodTimeZoneCell(style: .Default, reuseIdentifier: "PeriodTimeZoneCell")
            cell.nameLabel.text = periodTimeZone?.name
            cell.colorMark.color = periodTimeZone?.color
            return cell
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("PeriodStartTimeCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "PeriodStartTimeCell")
                cell.detailTextLabel?.monospaceDigits()
                cell.detailTextLabel?.text = periodStartTime?.shortString
                cell.detailTextLabel?.textColor = warningCellType == nil ? normalTextColor : warningTextColor
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("PeriodEndTimeCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "PeriodEndTimeCell")
                cell.detailTextLabel?.monospaceDigits()
                cell.detailTextLabel?.text = periodEndTime?.shortString
                cell.detailTextLabel?.textColor = warningCellType == nil ? normalTextColor : warningTextColor
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("PeriodTimeWarningCell") as? PeriodTimeWarningCell ?? PeriodTimeWarningCell(style: .Default, reuseIdentifier: "PeriodTimeWarningCell")
                
                if let warningCellType = warningCellType {
                    switch warningCellType {
                    case .StartsAtEnd:
                        cell.warningLabel.text = "The period cannot finish when it starts"
                    case .StartsAfterEnd:
                        cell.warningLabel.text = "The start time occurs after the end time"
                    case .Overlap:
                        cell.warningLabel.text = "Period overlaps with another period"
                    }
                }
                
                return cell
            default:
                break
            }
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("DeletePeriodCell") ?? UITableViewCell(style: .Default , reuseIdentifier: "DeletePeriodCell")
            return cell
        default: break
        }
        
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension PeriodController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 3 {
            showDeleteConfirmation()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
