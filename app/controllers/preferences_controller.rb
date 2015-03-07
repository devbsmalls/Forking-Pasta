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

  def timeIntervalDidChange(sender)
    FkP.fiveMinuteIntervals = sender.selectedSegmentIndex
    cdq.save
  end


  #### table view delegate methods ####

  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0
      1
    when 1
      Category.count
    end
  end

  def tableView(tableView, titleForHeaderInSection: section)
    case section
    when 0
      nil
    when 1
      "Categories"
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      cell = tableView.dequeueReusableCellWithIdentifier("TimePickerIntervalCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "TimePickerIntervalCell")
      cell.timeIntervalControl.selectedSegmentIndex = 0 if FkP.fiveMinuteIntervals? == false
      cell
    when 1
      cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "CategoryCell")
      category = Category.where(:index).eq(indexPath.row).first
      cell.nameLabel.text = category.name
      cell.colorMark.color = category.color

      cell
    end
  end

end