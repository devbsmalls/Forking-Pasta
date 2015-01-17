class WakeBedTimeController < UIViewController
  extend IB

  attr_accessor :isWake

  outlet :timePicker, UIDatePicker

  def viewDidLoad
    super

    # ensures picker shows the time it is handed
    @timePicker.timeZone = NSTimeZone.timeZoneWithName("UTC")

    # setting in IB doesn't allow 23:00 because of timezone shit
    @timePicker.maximumDate = Time.at(0).utc
    @timePicker.minimumDate = Time.at(23*3600 + 59*60 + 59).utc
    
    if @isWake
      @timePicker.date = Day.wake_time || Time.at(9*60*60 + 0*60 + 0).utc
    else
      self.navigationItem.title = "Bed Time"
      @timePicker.date = Day.bed_time || Time.at(22*60*60 + 30*60 + 0).utc
    end

  end

  def done

    if @isWake
      Day.wake_time = @timePicker.date.utc.strip_date
    else
      Day.bed_time = @timePicker.date.utc.strip_date
    end

    self.navigationController.popViewControllerAnimated(true)
  end

end