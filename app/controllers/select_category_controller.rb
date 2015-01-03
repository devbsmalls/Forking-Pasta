class SelectCategoryController < UITableViewController

  attr_accessor :period

  def viewWillAppear(animated)
    if @needsReload
      self.tableView.reloadData
      @needsReload = false
    end
  end

  def toggleEditing(sender)
    self.tableView.isEditing ? sender.setTitle("Edit", forState: UIControlStateNormal) : sender.setTitle("Done", forState: UIControlStateNormal)
    self.tableView.setEditing(!self.tableView.isEditing, animated: true)
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
    if self.tableView.isEditing
      editController = storyboard.instantiateViewControllerWithIdentifier("EditCategoryController")
      editController.category = Category.where(:index).eq(indexPath.row).first
      @needsReload = true

      self.navigationController.pushViewController(editController, animated: true)
    else
      @period.category = Category.where(:index).eq(indexPath.row).first
      
      self.navigationController.popViewControllerAnimated(true)
    end
  end

  def tableView(tableView, editingStyleForRowAtIndexPath: indexPath)
    UITableViewCellEditingStyleNone
  end

  def tableView(tableView, shouldIndentWhileEditingRowAtIndexPath: indexPath)
    false
  end

end