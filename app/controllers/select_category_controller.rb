class SelectCategoryController < UITableViewController

  attr_accessor :period

  def viewWillAppear(animated)
    if @needsReload
      self.tableView.reloadData
      @needsReload = false
    end
  end

  def prepareForSegue(segue, sender: sender)
    if segue.identifier == "EditCategorySegue"
      segue.destinationViewController.category = period.category
    end

    @needsReload = true
  end

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
    if @period.category
      cell.accessoryType = UITableViewCellAccessoryCheckmark if category == @period.category
    end
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    @period.category = Category.where(:index).eq(indexPath.row).first
    
    self.navigationController.popViewControllerAnimated(true)
  end

end