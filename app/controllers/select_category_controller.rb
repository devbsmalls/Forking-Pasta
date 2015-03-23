class SelectCategoryController < UITableViewController

  attr_accessor :scratch_period

  #### table view delegate methods ####

  def tableView(tableView, numberOfRowsInSection: section)
    Category.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("SelectCategoryCell")
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "SelectCategoryCell")
    category = Category.where(:index).eq(indexPath.row).first
    cell.nameLabel.text = category.name
    cell.colorMark.color = category.color
    if @scratch_period[:category]
      cell.accessoryType = UITableViewCellAccessoryCheckmark if category == @scratch_period[:category]
    end
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    @scratch_period[:category] = Category.where(:index).eq(indexPath.row).first
    
    self.navigationController.popViewControllerAnimated(true)
  end

end