import UIKit
import KingPastaKit

class SelectCategoryController: UITableViewController {
    
    var delegate: PeriodController!
    var periodCategory: KPCategory?
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return KPCategory.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectCategoryCell") as? SelectCategoryCell ??
            SelectCategoryCell(style: .Default, reuseIdentifier: "SelectCategoryCell")
        let category = KPCategory.forIndex(indexPath.row)
        cell.nameLabel.text = category.name
        cell.colorMark.color = category.color
        if let periodCategory = periodCategory where category == periodCategory {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.periodCategory = KPCategory.forIndex(indexPath.row)
        navigationController?.popViewControllerAnimated(true)
    }
}