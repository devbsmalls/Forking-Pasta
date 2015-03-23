class ScheduleDaysController < UITableViewController
  extend IB

  attr_accessor :schedule

  def viewDidLoad
    super

    @schedule_days = @schedule.days.array
  end

  def save
    @schedule.days.each { |d| d.schedule = nil }      # remove this schedule from all day objects
    @schedule_days.each { |d| @schedule.days << d }   # add the new days back to this schedule
    FkP.save unless @schedule.name.nil?   # don't save if the schedule hasn't been named yet

    self.navigationController.popViewControllerAnimated(true)
  end

  def cancel
    # do nothing, edited variables will simply be deleted

    self.navigationController.popViewControllerAnimated(true)
  end


  #### table view delegate methods ####

  def tableView(tableView, numberOfRowsInSection: section)
    Day.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("DayCell")
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "DayCell")
    
    day = Day.wday(indexPath.row)
    cell.textLabel.text = day.name

    cell.accessoryType = UITableViewCellAccessoryCheckmark if @schedule_days.include?(day)

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    cell = tableView.cellForRowAtIndexPath(indexPath)

    if cell.accessoryType == UITableViewCellAccessoryCheckmark
      @schedule_days.reject! { |d| d == Day.wday(indexPath.row) }
      cell.accessoryType = UITableViewCellAccessoryNone
    else
      @schedule_days << Day.wday(indexPath.row)
      cell.accessoryType = UITableViewCellAccessoryCheckmark
    end

    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  end

end