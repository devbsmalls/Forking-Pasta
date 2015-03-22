class ScheduleDaysController < UITableViewController
  extend IB

  attr_accessor :schedule

  def save
    FkP.save unless @schedule.name.nil?   # don't save if the schedule hasn't been named yet

    self.navigationController.popViewControllerAnimated(true)
  end

  def cancel
    cdq.contexts.current.rollback

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

    cell.accessoryType = UITableViewCellAccessoryCheckmark if @schedule.days.all.include?(day)

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    cell = tableView.cellForRowAtIndexPath(indexPath)

    if cell.accessoryType == UITableViewCellAccessoryCheckmark
      @schedule.days = NSSet.setWithArray(@schedule.days.reject { |d| d == Day.wday(indexPath.row) })
      cell.accessoryType = UITableViewCellAccessoryNone
    else
      @schedule.days << Day.wday(indexPath.row)
      cell.accessoryType = UITableViewCellAccessoryCheckmark
    end

    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  end

end