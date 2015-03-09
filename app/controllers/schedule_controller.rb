class ScheduleController < UITableViewController
  extend IB

  def viewDidLoad
    super

    @schedules = Schedule.all.sort_by(:name)
  end

  def viewWillAppear(animated)
    super

    self.navigationController.setToolbarHidden(false, animated)
    updateHintImageView

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
    FkP.schedule_notifications
    self.navigationController.presentingViewController.dismissModalViewControllerAnimated(true)
  end

  def updateHintImageView
    if @schedules.count < 1
      hintImageView = UIImageView.alloc.initWithImage(UIImage.imageNamed("schedules_hint"))
      hintImageView.contentMode = UIViewContentModeBottom
      self.tableView.backgroundView = hintImageView
    else
      self.tableView.backgroundView = nil
    end
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

        cell.detailTextLabel.text = FkP.wake_time.utc.strftime("%H:%M")

        cell
      when 1
        cell = tableView.dequeueReusableCellWithIdentifier("BedTimeCell")
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "BedTimeCell")

        cell.detailTextLabel.text = FkP.bed_time.utc.strftime("%H:%M")

        cell
      end
    when 1
      cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "ScheduleCell")
      schedule = @schedules[indexPath.row]

      unless schedule.name.nil? || schedule.name.empty?
        cell.textLabel.text = schedule.name
      else
        cell.textLabel.text = "Unnamed Schedule"
      end
      cell.detailTextLabel.text = schedule.days_string

      cell
    end
  end

  def tableView(tableView, canEditRowAtIndexPath: indexPath)
    indexPath.section == 1 ? true : false
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    if indexPath.section == 1
      @schedules[indexPath.row].destroy
      cdq.save
      
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade) if editingStyle == UITableViewCellEditingStyleDelete
      updateHintImageView
    end
  end

end
