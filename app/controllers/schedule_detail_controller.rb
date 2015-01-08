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
  end

  def viewWillDisappear(animated)
    super
    self.navigationController.setToolbarHidden(true, animated)
  end

  def save
    self.navigationController.popViewControllerAnimated(true)
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when "EditPeriodSegue"
      indexPath = self.tableView.indexPathForSelectedRow
      segue.destinationViewController.period = @periods[indexPath.row]
    when "AddPeriodSegue"
      segue.destinationViewController.schedule = @schedule
    when "SelectDaysSegue"
      segue.destinationViewController.schedule = @schedule
    end
    
    @needsReload = true
  end

  def nameDidChange(sender)
    @schedule.name = sender.text
    cdq.save    # could this save unwanted things?
  end


  #### text field delegate methods ####
  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
  end


  #### table view delegate methods ####

  def numberOfSectionsInTableView(tableView)
    3
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0..1
      1
    when 2
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
      days = ""
      shortDays = NSDateFormatter.new.shortWeekdaySymbols
      schedule.days.sort_by(:dayOfWeek).each do |day|
        days << shortDays[day.dayOfWeek] + " "
      end
      cell.detailTextLabel.text = days
      
      cell
    when 2
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

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    @periods[indexPath.row].destroy
    cdq.save
    
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade) if editingStyle == UITableViewCellEditingStyleDelete
  end

end