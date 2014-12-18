class SelectCategoryController < UITableViewController

  attr_accessor :period

  def tableView(tableView, numberOfRowsInSection: section)
    Category.symbols.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("SelectCategoryCell")
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "SelectCategoryCell")
    cell.textLabel.text = Category.symbols[indexPath.row]
    if @period.category
      cell.accessoryType = UITableViewCellAccessoryCheckmark if Category.symbols[indexPath.row] == @period.category.to_sym
    end
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    category = Category.symbols[indexPath.row]
    @period.category = category
    
    self.navigationController.popViewControllerAnimated(true)
  end

end