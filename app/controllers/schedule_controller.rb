class ScheduleController < UITableViewController
  extend IB

  def viewDidLoad
    super

    @schedules = Schedule.all.sort_by(:name)
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
    self.navigationController.setToolbarHidden(true, animated)
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when "EditScheduleSegue"
      indexPath = self.tableView.indexPathForSelectedRow
      segue.destinationViewController.schedule = @schedules[indexPath.row]
    end
    
    @needsReload = true
  end

  def done
    self.navigationController.presentingViewController.dismissModalViewControllerAnimated(true)
  end

  #### table view delegate methods ####

  def tableView(tableView, numberOfRowsInSection: section)
    Schedule.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell")
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "ScheduleCell")
    schedule = @schedules[indexPath.row]

    cell.textLabel.text = schedule.name
    cell.detailTextLabel.text = schedule.days_string

    cell
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    @schedules[indexPath.row].destroy
    cdq.save
    
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade) if editingStyle == UITableViewCellEditingStyleDelete
  end

end
