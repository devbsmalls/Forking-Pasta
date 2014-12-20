class SetTimeController < UIViewController
  extend IB

  attr_accessor :period, :isStart

  outlet :timePicker, UIDatePicker

  def viewDidLoad
    super

    # ensures picker shows the time it is handed
    @timePicker.timeZone = NSTimeZone.timeZoneWithName("UTC")

    # setting in IB doesn't allow 23:00 because of timezone shit
    @timePicker.maximumDate = Time.at(0).utc
    @timePicker.minimumDate = Time.at(23*3600 + 59*60 + 59).utc
    
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