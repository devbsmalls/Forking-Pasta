import UIKit
import KingPastaKit

class SelectTimeZoneController: UITableViewController {
    
    var delegate: PeriodController!
    var periodTimeZone: TimeZone?
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TimeZone.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectTimeZoneCell") as? SelectTimeZoneCell ??
            SelectTimeZoneCell(style: .Default, reuseIdentifier: "SelectTimeZoneCell")
        let timeZone = TimeZone.forIndex(indexPath.row)
        cell.nameLabel.text = timeZone.name
        cell.colorMark.color = timeZone.color
        if let periodTimeZone = periodTimeZone where timeZone == periodTimeZone {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.periodTimeZone = TimeZone.forIndex(indexPath.row)
        navigationController?.popViewControllerAnimated(true)
    }
}