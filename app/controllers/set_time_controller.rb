class SetTimeController < UIViewController
  extend IB

  attr_accessor :period, :isStart

  outlet :timePicker, UIDatePicker

  def viewDidLoad
    super

    @timePicker.timeZone = NSTimeZone.timeZoneWithName("UTC")
    
    if @isStart
      @timePicker.date = @period.startTime || Day::WAKEUP
    else
      self.navigationItem.title = "End Time"
      @timePicker.date = @period.endTime || @period.startTime || Day::WAKEUP
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

end