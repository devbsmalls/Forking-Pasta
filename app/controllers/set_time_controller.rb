class SetTimeController < UIViewController
  extend IB

  attr_accessor :period, :isStart

  outlet :timeIntervalControl, UISegmentedControl
  outlet :timePicker, UIDatePicker

  def viewDidLoad
    super

    # ensures picker shows the time it is handed
    @timePicker.timeZone = NSTimeZone.timeZoneWithName("UTC")

    # setting in IB doesn't allow 23:00 because of timezone shit
    @timePicker.maximumDate = Time.at(0).utc
    @timePicker.minimumDate = Time.at(23*3600 + 59*60 + 59).utc
    
    if @isStart
      @timePicker.date = @period.startTime || @period.schedule.ends || FkP.wake_time
    else
      self.navigationItem.title = "End Time"
      @timePicker.date = @period.endTime || @period.startTime || FkP.bed_time
    end

    if @timePicker.date.min % 5 != 0
      @timePicker.minuteInterval = 1
      @timeIntervalControl.selectedSegmentIndex = 0
    end

  end

  def done

    if @isStart
      @period.startTime = @timePicker.date.utc.strip_date
    else
      @period.endTime = @timePicker.date.utc.strip_date
    end

    self.navigationController.popViewControllerAnimated(true)
  end

  def timeIntervalDidChange
    if @timeIntervalControl.selectedSegmentIndex == 0
      @timePicker.minuteInterval = 1
    else
      @timePicker.minuteInterval = 5
      @timePicker.date -= (@timePicker.date.min % 5) * 60
    end
  end

end