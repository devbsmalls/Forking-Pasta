class DetailController < UITableViewController
  extend IB

  attr_accessor :period, :dayIndex

  outlet :saveButton, UIBarButtonItem
  
  def viewDidLoad
    super

    self.navigationItem.title = "Edit Period" unless @period.nil?
    @period ||= Period.new
  end

  def viewWillAppear(animated)
    if @needsReload
      self.tableView.reloadData
      @needsReload = false
    end

    validate
  end

  def prepareForSegue(segue, sender: sender)
    if segue.identifier == "SelectCategorySegue"
      segue.destinationViewController.period = period
    elsif segue.identifier == "SetStartTimeSegue"
      segue.destinationViewController.period = period
      segue.destinationViewController.isStart = true
    elsif segue.identifier == "SetEndTimeSegue"
      segue.destinationViewController.period = period
      segue.destinationViewController.isStart = false
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
    end
    valid = false if @period.schedule.nil?
    
    @saveButton.enabled = valid
  end

  def save
    cdq.save

    self.navigationController.popViewControllerAnimated(true)
  end

  def cancel
    cdq.contexts.current.rollback   # would be great to just cdq.rollback

    self.navigationController.popViewControllerAnimated(true)
  end

  def nameDidChange(sender)
    @period.name = sender.text
    validate
  end

  def daysDidChange(sender)
    @period.schedule = Schedule.on_wday(sender.tag)
    self.tableView.reloadData   # temporary hack to work around schedule->day mapping

    validate
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
      7
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      cell = tableView.dequeueReusableCellWithIdentifier("PeriodNameCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodNameCell")
      @nameTextField = cell.nameTextField
      @nameTextField.delegate = self
      @nameTextField.text = @period.name
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
      cell = tableView.dequeueReusableCellWithIdentifier("PeriodDayCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodDayCell")
      
      day = Day.wday(indexPath.row)

      cell.dayLabel.text = day.name
      cell.daySwitch.tag = indexPath.row
      cell.daySwitch.on = false
      
      if @dayIndex
        @period.schedule = Schedule.on_wday(@dayIndex)
        @dayIndex = nil
      end

      # temporary hack for 1 schedule per day
      @period.schedule.days.each do |d|
        cell.daySwitch.on = true if d.dayOfWeek == indexPath.row
      end
      cell
    end
  end

end