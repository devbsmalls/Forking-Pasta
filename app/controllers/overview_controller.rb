class OverviewController < UITableViewController
  extend IB

  outlet :dayControl, UISegmentedControl

  def viewDidLoad
    super

    NSDateFormatter.new.shortWeekdaySymbols.each_with_index do |day, index|
      @dayControl.setTitle(day, forSegmentAtIndex: index)
    end

    @periods = Period.all_on_wday(@dayControl.selectedSegmentIndex)
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
    @periods = Period.all_on_wday(@dayControl.selectedSegmentIndex)
    tableView.reloadData
  end


  #### table view delegate methods ####

  def tableView(tableView, numberOfRowsInSection: section)
    if @periods
      @periods.count
    else
     0
   end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
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

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)

    @periods[indexPath.row].destroy
    cdq.save
    
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade) if editingStyle == UITableViewCellEditingStyleDelete

  end

end