class OverviewController < UITableViewController
  extend IB

  outlet :dayControl, UISegmentedControl

  def viewDidLoad
    super

    @days = Day::SYMBOLS
    @periods = Period.allOn(@days[@dayControl.selectedSegmentIndex])
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

  def dismiss
    self.navigationController.presentingViewController.dismissModalViewControllerAnimated(true)
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when "EditPeriodSegue"
      indexPath = self.tableView.indexPathForSelectedRow
      segue.destinationViewController.period = @periods[indexPath.row]
    when "AddPeriodSegue"
      segue.destinationViewController.dayIndex = @dayControl.selectedSegmentIndex
    end
    
    @needsReload = true
  end

  def dayChanged
    @periods = Period.allOn(@days[@dayControl.selectedSegmentIndex])
    tableView.reloadData
  end


  #### table view delegate methods ####

  def tableView(tableView, numberOfRowsInSection: section)
    @periods.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("PeriodCell")
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "PeriodCell")

    period = @periods[indexPath.row]

    cell.textLabel.text = period.name
    cell.detailTextLabel.text = "#{period.startTime.utc.strftime("%H:%M")} - #{period.endTime.utc.strftime("%H:%M")}"
    
    cell
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)

    @periods[indexPath.row].destroy
    cdq.save
    
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade) if editingStyle == UITableViewCellEditingStyleDelete

  end

end