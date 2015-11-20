import UIKit

class SelectCategoryController: UITableViewController {
    
    var delegate: PeriodController!
    var periodCategory: Category?
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectCategoryCell") as? SelectCategoryCell ??
            SelectCategoryCell(style: .Default, reuseIdentifier: "SelectCategoryCell")
        let category = Category.forIndex(indexPath.row)
        cell.nameLabel.text = category.name
        cell.colorMark.color = category.color
        if let periodCategory = periodCategory where category == periodCategory {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.periodCategory = Category.forIndex(indexPath.row)
        navigationController?.popViewControllerAnimated(true)
    }
}