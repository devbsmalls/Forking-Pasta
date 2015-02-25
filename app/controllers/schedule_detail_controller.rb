class ScheduleDetailController < UITableViewController
  extend IB

  attr_accessor :schedule

  def viewDidLoad
    super

    @schedule = Schedule.new if @schedule.nil?
    @periods = @schedule.all_periods
  end

  def viewWillAppear(animated)
    super
    
    self.navigationController.setToolbarHidden(false, animated)
    updateHintImageView

    if @needsReload
      self.tableView.reloadData
      @needsReload = false
    end

    if @showIndexPath
      self.tableView.scrollToRowAtIndexPath(@showIndexPath, atScrollPosition: UITableViewScrollPositionMiddle, animated: false)
      @showIndexPath = nil
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
    @showIndexPath = NSIndexPath.indexPathForRow(@periods.array.index(segue.sourceViewController.period), inSection: 3) if segue.sourceViewController.new_period
  end

  def nameDidChange(sender)
    @schedule.name = sender.text
    cdq.save    # could this save unwanted things?
  end

  def notificationsSwitchDidChange(sender)
    @schedule.shows_notifications = sender.isOn
    FkP.register_notifications if sender.isOn
  end

  def hideKeyboard
    self.view.endEditing(true)
  end


  #### text field delegate methods ####
  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
  end


  #### table view delegate methods ####

  def numberOfSectionsInTableView(tableView)
    4
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
    end
  end

  def tableView(tableView, canEditRowAtIndexPath: indexPath)
    indexPath.section == 3 ? true : false
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    if indexPath.section == 3
      @periods[indexPath.row].destroy
      cdq.save
      
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade) if editingStyle == UITableViewCellEditingStyleDelete
      updateHintImageView
    end
  end

end