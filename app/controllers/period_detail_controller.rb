class PeriodDetailController < UITableViewController
  extend IB

  attr_accessor :schedule, :period
  attr_reader :new_period

  outlet :saveButton, UIBarButtonItem
  
  def viewDidLoad
    super

    @scratch_period = {}

    if @period.nil?
      @new_period = true
      @scratch_period[:schedule] = @schedule
    else
      @editing = true
      self.navigationItem.title = "Edit Period"

      @scratch_period[:name] = @period.name
      @scratch_period[:category] = @period.category
      @scratch_period[:startTime] = @period.startTime
      @scratch_period[:endTime] = @period.endTime
      @scratch_period[:schedule] = @period.schedule
    end

    @warningTextColor ||= UIColor.alloc.initWithHue(359/360.0, saturation: 0.75, brightness: 1.0, alpha: 1.0)
  end

  def viewWillAppear(animated)
    super

    if @needsReload
      self.tableView.reloadData
      @needsReload = false
    end

    validate
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when "SelectCategorySegue"
      segue.destinationViewController.scratch_period = @scratch_period
    when "SetStartTimeSegue"
      segue.destinationViewController.scratch_period = @scratch_period
      segue.destinationViewController.isStart = true
    when "SetEndTimeSegue"
      segue.destinationViewController.scratch_period = @scratch_period
      segue.destinationViewController.isStart = false
    when "SaveUnwind"
      self.view.endEditing(true)

      @period ||= Period.new
      @period.name = @scratch_period[:name]
      @period.category = @scratch_period[:category]
      @period.startTime = @scratch_period[:startTime]
      @period.endTime = @scratch_period[:endTime]
      @period.schedule = @scratch_period[:schedule]
      @period.save if @new_period
      FkP.save
    end

    @needsReload = true
  end

  def validate
    valid = true
    valid = false if @scratch_period[:name].nil? || @scratch_period[:name].empty?
    valid = false if @scratch_period[:category].nil?  # or not == existing category
    if @scratch_period[:startTime].nil? || @scratch_period[:endTime].nil?
      valid = false
    else
      if @scratch_period[:endTime] == @scratch_period[:startTime]
        valid = false
        showTimeWarningOfType(:startsAtEnd)
      elsif @scratch_period[:endTime] < @scratch_period[:startTime]
        valid = false
        showTimeWarningOfType(:startsAfterEnd)
      elsif Period.overlap_with_start(@scratch_period[:startTime], end: @scratch_period[:endTime], schedule: @scratch_period[:schedule], ignoring: @period)
        valid = false
        showTimeWarningOfType(:overlap)
      else
        hideTimeWarning
      end
    end
    
    @saveButton.enabled = valid
  end

  def cancel
    # 

    self.navigationController.popViewControllerAnimated(true)
  end

  def nameDidChange(sender)
    @scratch_period[:name] = sender.text
    validate
  end

  def hideKeyboard
    # scrollview keyboard: “Dismiss on drag”.
    # gesture recognizer cancelsTouchesInView = false
    self.view.endEditing(true)
  end

  def showTimeWarningOfType(type)
    unless @warningCellType == type
      @warningCellType = type
      self.tableView.reloadSections(NSIndexSet.indexSetWithIndex(2), withRowAnimation: UITableViewRowAnimationNone)
      # self.tableView.insertRowsAtIndexPaths([NSIndexPath.indexPathForRow(2, inSection: 2)], withRowAnimation: UITableViewRowAnimationFade)
    end
  end

  def hideTimeWarning
    unless @warningCellType.nil?
      @warningCellType = nil
      self.tableView.reloadSections(NSIndexSet.indexSetWithIndex(2), withRowAnimation: UITableViewRowAnimationNone)
    end
  end

  def showDeleteConfirmation
    self.view.endEditing(true)  # ensure any changes are merged into period before deleting

    confirmSheet = UIAlertController.alertControllerWithTitle("Delete #{@scratch_period[:name]}?", message: "Do you really want to delete this period?", preferredStyle: UIAlertControllerStyleActionSheet)
    confirmSheet.addAction(UIAlertAction.actionWithTitle("Delete", style: UIAlertActionStyleDestructive, handler: lambda { |action|
      deletePeriod
    }))
    confirmSheet.addAction(UIAlertAction.actionWithTitle("Cancel", style: UIAlertActionStyleCancel, handler: nil))
    self.presentViewController(confirmSheet, animated: true, completion: nil)
  end

  def deletePeriod
    @period.destroy
    FkP.save

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
      @warningCellType.nil? ? 2 : 3
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
      cell.nameTextField.text = @scratch_period[:name]
      cell
    when 1
      cell = tableView.dequeueReusableCellWithIdentifier("PeriodCategoryCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodCategoryCell")
      cell.nameLabel.text = @scratch_period[:category].name unless @scratch_period[:category].nil?
      cell.colorMark.color = @scratch_period[:category].color unless @scratch_period[:category].nil?
      cell
    when 2
      case indexPath.row
      when 0
        cell = tableView.dequeueReusableCellWithIdentifier("PeriodStartTimeCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodStartTimeCell")
        cell.detailTextLabel.text = @scratch_period[:startTime].utc.strftime("%H:%M") if @scratch_period[:startTime]
        
        @normalTextColor ||= cell.detailTextLabel.textColor
        cell.detailTextLabel.textColor = @warningCellType.nil? ? @normalTextColor : @warningTextColor
        
        cell
      when 1
        cell = tableView.dequeueReusableCellWithIdentifier("PeriodEndTimeCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodEndTimeCell")
        cell.detailTextLabel.text = @scratch_period[:endTime].utc.strftime("%H:%M") if @scratch_period[:endTime]
        
        @normalTextColor ||= cell.detailTextLabel.textColor
        cell.detailTextLabel.textColor = @warningCellType.nil? ? @normalTextColor : @warningTextColor
        
        cell
      when 2
        cell = tableView.dequeueReusableCellWithIdentifier("PeriodTimeWarningCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodTimeWarningCell")
        
        case @warningCellType
        when :startsAtEnd
          cell.warningLabel.text = "The period cannot finish when it starts"
        when :startsAfterEnd
          cell.warningLabel.text = "The start time occurs after the end time"
        when :overlap
          cell.warningLabel.text = "Period overlaps with another period"
        end

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