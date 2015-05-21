class ScheduleController < UITableViewController
  extend IB

  def viewDidLoad
    super

    @schedules = Schedule.order(:name).array
  end

  def viewWillAppear(animated)
    super

    self.navigationController.setToolbarHidden(false, animated)

    if @needsReload
      @schedules = Schedule.order(:name).array
      self.tableView.reloadData
      @needsReload = false
    end

    updateHintImageView   # after reload check to ensure correct number of periods
  end

  def viewDidAppear(animated)
    super

    show_getting_started #unless FkP.getting_started_seen?
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

  def show_getting_started
    getting_started = storyboard.instantiateViewControllerWithIdentifier("WalkthroughController")
    self.presentModalViewController(getting_started, animated: true)

    FkP.getting_started_seen = true
    FkP.save
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
      @schedules.count
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
      
      if schedule.name.nil? || schedule.name.empty?
        cell.textLabel.text = "Unnamed Schedule"
      else
        cell.textLabel.text = schedule.name
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
      deleted_schedule = @schedules.delete_at(indexPath.row)
      deleted_schedule.days.each { |d| d.schedule = nil }
      deleted_schedule.destroy
      FkP.save
      
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade) if editingStyle == UITableViewCellEditingStyleDelete
      updateHintImageView
    end
  end

end
