class ScheduleDetailController < UITableViewController
  extend IB

  attr_accessor :schedule

  def viewDidLoad
    super

    @editing = true unless @schedule.nil?
    @schedule = Schedule.create if @schedule.nil?
    @periods = @schedule.all_periods.array
  end

  def viewWillAppear(animated)
    super
    
    self.navigationController.setToolbarHidden(false, animated)
    updateHintImageView

    if @needsReload
      @periods = @schedule.all_periods.array
      self.tableView.reloadData
      @needsReload = false
    end

    if @showPeriod
      indexPath = NSIndexPath.indexPathForRow(@periods.index(@showPeriod), inSection: 3)
      self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPositionMiddle, animated: false)
      @showPeriod = nil
    end
  end

  def willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
    updateHintImageView
  end

  def viewWillDisappear(animated)
    super
    self.navigationController.setToolbarHidden(true, animated)
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when "SelectDaysSegue"
      segue.destinationViewController.schedule = @schedule
    when "EditPeriodSegue"
      indexPath = self.tableView.indexPathForSelectedRow
      segue.destinationViewController.period = @periods[indexPath.row]
    when "AddPeriodSegue"
      segue.destinationViewController.schedule = @schedule
      segue.destinationViewController.new_period = true
    end
    
    @needsReload = true
  end

  def save
    self.view.endEditing(true)    # this might need to be called on back too (somehow!)
    self.navigationController.popViewControllerAnimated(true)
  end

  def updateHintImageView
    if @periods.count < 1 && (UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait || UIScreen.mainScreen.bounds.size.height == 736 || UIScreen.mainScreen.bounds.size.height == 414)
      hintImageView = UIImageView.alloc.initWithImage(UIImage.imageNamed("periods_hint"))
      hintImageView.contentMode = UIViewContentModeBottom
      self.tableView.backgroundView = hintImageView
    else
      self.tableView.backgroundView = nil
    end
  end

  ib_action :showPeriodFromSegue, UIStoryboardSegue
  def showPeriodFromSegue(segue)
    @showPeriod = segue.sourceViewController.period if segue.sourceViewController.new_period
  end

  def nameDidChange(sender)
    @schedule.name = sender.text
    FkP.save    # could this save unwanted things?
  end

  def notificationsSwitchDidChange(sender)
    @schedule.shows_notifications = sender.isOn
    FkP.register_notifications if sender.isOn
  end

  def hideKeyboard
    self.view.endEditing(true)
  end

  def showDeleteConfirmation
    self.view.endEditing(true)  # ensure any changes are merged into schedule before deleting

    confirmSheet = UIAlertController.alertControllerWithTitle("Delete #{@schedule.name}?", message: "Do you really want to delete this schedule?", preferredStyle: UIAlertControllerStyleActionSheet)
    confirmSheet.addAction(UIAlertAction.actionWithTitle("Delete", style: UIAlertActionStyleDestructive, handler: lambda { |action|
      deleteSchedule
    }))
    confirmSheet.addAction(UIAlertAction.actionWithTitle("Cancel", style: UIAlertActionStyleCancel, handler: nil))
    self.presentViewController(confirmSheet, animated: true, completion: nil)
  end

  def deleteSchedule
    @schedule.destroy
    FkP.save

    self.navigationController.popViewControllerAnimated(true)
  end


  #### text field delegate methods ####
  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
  end


  #### table view delegate methods ####

  def numberOfSectionsInTableView(tableView)
    @editing ? 5 : 4
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0..2
      1
    when 3
      if @periods
        @periods.count
      else
       0
      end
    when 4
      1
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      cell = tableView.dequeueReusableCellWithIdentifier("ScheduleNameCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "ScheduleNameCell")
      cell.nameTextField.delegate = self
      cell.nameTextField.text = @schedule.name
      cell.nameTextField.becomeFirstResponder if @schedule.name.nil?
      
      cell
    when 1
      cell = tableView.dequeueReusableCellWithIdentifier("ScheduleDaysCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "ScheduleDaysCell")
      cell.detailTextLabel.text = @schedule.days_string
      
      cell
    when 2
      cell = tableView.dequeueReusableCellWithIdentifier("ScheduleNotificationsCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "ScheduleNotificationsCell")
      cell.notificationsSwitch.on = @schedule.shows_notifications?
      
      cell
    when 3
      cell = tableView.dequeueReusableCellWithIdentifier("PeriodCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodCell")

      if @periods
        period = @periods[indexPath.row]

        cell.categoryColorMark.color = period.category.color
        cell.periodNameLabel.text = period.name
        cell.timeRangeLabel.text = "#{period.startTime.utc.strftime("%H:%M")} - #{period.endTime.utc.strftime("%H:%M")}"
      end
      
      cell
    when 4
      cell = tableView.dequeueReusableCellWithIdentifier("DeleteScheduleCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault , reuseIdentifier: "DeleteScheduleCell")
      cell
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    if indexPath.section == 4
      showDeleteConfirmation
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    end
  end

  def tableView(tableView, canEditRowAtIndexPath: indexPath)
    indexPath.section == 3 ? true : false
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    if indexPath.section == 3
      @periods[indexPath.row].destroy
      FkP.save
      
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade) if editingStyle == UITableViewCellEditingStyleDelete
      updateHintImageView
    end
  end

end