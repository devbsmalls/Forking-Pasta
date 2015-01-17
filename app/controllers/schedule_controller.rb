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
    super
    
    self.navigationController.setToolbarHidden(true, animated)
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when "WakeTimeSegue"
      segue.destinationViewController.isWake = true
    when "BedTimeSegue"
      segue.destinationViewController.isWake = false
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

  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0
      2
    when 1
      Schedule.count
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      case indexPath.row
      when 0
        cell = tableView.dequeueReusableCellWithIdentifier("WakeTimeCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "WakeTimeCell")

        cell.detailTextLabel.text = Day.wake_time.utc.strftime("%H:%M")

        cell
      when 1
        cell = tableView.dequeueReusableCellWithIdentifier("BedTimeCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "BedTimeCell")

        cell.detailTextLabel.text = Day.bed_time.utc.strftime("%H:%M")

        cell
      end
    when 1
      cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "ScheduleCell")
      schedule = @schedules[indexPath.row]

      cell.textLabel.text = schedule.name
      cell.detailTextLabel.text = schedule.days_string

      cell
    end
  end

  def tableView(tableView, canEditRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      false
    else
      true
    end 
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    if indexPath.section == 1
      @schedules[indexPath.row].destroy
      cdq.save
      
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade) if editingStyle == UITableViewCellEditingStyleDelete
    end
  end

end
