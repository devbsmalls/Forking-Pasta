class PeriodDetailController < UITableViewController
  extend IB

  attr_accessor :schedule, :period, :new_period

  outlet :saveButton, UIBarButtonItem
  
  def viewDidLoad
    super

    unless @period.nil?
      @editing = true
      self.navigationItem.title = "Edit Period"
    end

    @period ||= Period.new
  end

  def viewWillAppear(animated)
    super

    if @needsReload
      self.tableView.reloadData
      @needsReload = false
    end

    validate
  end

  def viewDidAppear(animated)
    if @schedule
      @period.schedule = @schedule
      @schedule = nil
    end
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when "SelectCategorySegue"
      segue.destinationViewController.period = period
    when "SetStartTimeSegue"
      segue.destinationViewController.period = period
      segue.destinationViewController.isStart = true
    when "SetEndTimeSegue"
      segue.destinationViewController.period = period
      segue.destinationViewController.isStart = false
    when "SaveUnwind"
      self.view.endEditing(true)
      cdq.save
    end

    @needsReload = true
  end

  def validate
    valid = true
    valid = false if @period.name.nil? || @period.name.empty?
    valid = false if @period.category.nil?  # or not == existing category
    if @period.startTime.nil? || @period.endTime.nil?
      valid = false
    else
      valid = false if @period.endTime <= @period.startTime
      valid = false if @period.has_overlap?
    end
    
    @saveButton.enabled = valid
  end

  def cancel
    self.view.endEditing(true)
    cdq.contexts.current.rollback

    self.navigationController.popViewControllerAnimated(true)
  end

  def nameDidChange(sender)
    @period.name = sender.text
    validate
  end

  def hideKeyboard
    # scrollview keyboard: “Dismiss on drag”.
    # gesture recognizer cancelsTouchesInView = false
    self.view.endEditing(true)
  end

  def showDeleteConfirmation
    self.view.endEditing(true)  # ensure any changes are merged into period before deleting

    confirmSheet = UIAlertController.alertControllerWithTitle("Delete #{@period.name}?", message: "Do you really want to delete this period?", preferredStyle: UIAlertControllerStyleActionSheet)
    confirmSheet.addAction(UIAlertAction.actionWithTitle("Delete", style: UIAlertActionStyleDestructive, handler: lambda { |action|
      deletePeriod
    }))
    confirmSheet.addAction(UIAlertAction.actionWithTitle("Cancel", style: UIAlertActionStyleCancel, handler: nil))
    self.presentViewController(confirmSheet, animated: true, completion: nil)
  end

  def deletePeriod
    @period.destroy
    cdq.save

    self.navigationController.popViewControllerAnimated(true)
  end


  #### text field delegate methods ####
  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
  end


  #### table view delegate methods ####

  def numberOfSectionsInTableView(tableView)
    @editing ? 4 : 3
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0..1
      1
    when 2
      2
    when 3
      1
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      cell = tableView.dequeueReusableCellWithIdentifier("PeriodNameCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodNameCell")
      cell.nameTextField.delegate = self
      cell.nameTextField.text = @period.name
      cell
    when 1
      cell = tableView.dequeueReusableCellWithIdentifier("PeriodCategoryCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodCategoryCell")
      cell.nameLabel.text = @period.category.name unless @period.category.nil?
      cell.colorMark.color = @period.category.color unless @period.category.nil?
      cell
    when 2
      case indexPath.row
      when 0
        cell = tableView.dequeueReusableCellWithIdentifier("PeriodStartTimeCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodStartTimeCell")
        cell.detailTextLabel.text = @period.startTime.utc.strftime("%H:%M") if @period.startTime
        cell
      when 1
        cell = tableView.dequeueReusableCellWithIdentifier("PeriodEndTimeCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodEndTimeCell")
        cell.detailTextLabel.text = @period.endTime.utc.strftime("%H:%M") if @period.endTime
        cell
      end
    when 3
      cell = tableView.dequeueReusableCellWithIdentifier("DeletePeriodCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault , reuseIdentifier: "DeletePeriodCell")
      cell
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    if indexPath.section == 3
      showDeleteConfirmation
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    end
  end

end