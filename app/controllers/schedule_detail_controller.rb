class ScheduleDetailController < UITableViewController
  extend IB

  attr_accessor :schedule

  def viewDidLoad
    super

    if @schedule.nil?
      @schedule = Schedule.new
      @periods = @schedule.all_periods
    else
      @periods = @schedule.all_periods
    end
  end

  def viewWillAppear(animated)
    super
    
    self.navigationController.setToolbarHidden(false, animated)

    if @needsReload
      self.tableView.reloadData
      @needsReload = false
    end

    if @showIndexPath
      self.tableView.scrollToRowAtIndexPath(@showIndexPath, atScrollPosition: UITableViewScrollPositionMiddle, animated: false)
      @showIndexPath = nil
    end
  end

  def viewWillDisappear(animated)
    super
    self.navigationController.setToolbarHidden(true, animated)
  end

  def save
    self.view.endEditing(true)    # this might need to be called on back too (somehow!)
    self.navigationController.popViewControllerAnimated(true)
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when "WakeTimeSegue"
      segue.destinationViewController.isWake = true
      segue.destinationViewController.schedule = @schedule
    when "BedTimeSegue"
      segue.destinationViewController.isWake = false
      segue.destinationViewController.schedule = @schedule
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

  ib_action :showPeriodFromSegue, UIStoryboardSegue
  def showPeriodFromSegue(segue)
    @showIndexPath = NSIndexPath.indexPathForRow(@periods.array.index(segue.sourceViewController.period), inSection: 3) if segue.sourceViewController.new_period
  end

  def nameDidChange(sender)
    @schedule.name = sender.text
    cdq.save    # could this save unwanted things?
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
    when 0..1
      1
    when 2
      2
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
      
      cell
    when 1
      cell = tableView.dequeueReusableCellWithIdentifier("ScheduleDaysCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "ScheduleDaysCell")
      cell.detailTextLabel.text = schedule.days_string
      
      cell
    when 2
      case indexPath.row
      when 0
        cell = tableView.dequeueReusableCellWithIdentifier("WakeTimeCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "WakeTimeCell")

        cell.detailTextLabel.text = @schedule.wakeTime.utc.strftime("%H:%M")

        cell
      when 1
        cell = tableView.dequeueReusableCellWithIdentifier("BedTimeCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "BedTimeCell")

        cell.detailTextLabel.text = @schedule.bedTime.utc.strftime("%H:%M")

        cell
      end
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
    end
  end

end