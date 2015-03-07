class PreferencesController < UITableViewController

  def prepareForSegue(segue, sender: sender)
    selectedIndexPath = self.tableView.indexPathForSelectedRow

    if segue.identifier == "EditCategorySegue"
      @needsReload = true
      segue.destinationViewController.category = Category.where(:index).eq(selectedIndexPath.row).first
    end
  end

  def done
    self.navigationController.presentingViewController.dismissModalViewControllerAnimated(true)
  end

  def viewWillAppear(animated)
    if @needsReload
      self.tableView.reloadData
      @needsReload = false
    end
  end

  #### table view delegate methods ####

  def tableView(tableView, numberOfRowsInSection: section)
    Category.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell")
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "CategoryCell")
    category = Category.where(:index).eq(indexPath.row).first
    cell.nameLabel.text = category.name
    cell.colorMark.color = category.color

    cell
  end

end