class SetTimeController < UIViewController
  extend IB

  attr_accessor :period, :isStart

  LINE_WIDTH = 1 / UIScreen.mainScreen.scale

  outlet :infoLabel, UILabel
  outlet :timePicker, UIDatePicker
  outlet :jumpToTimeView, UIView
  outlet :scheduleStartButton, UIButton
  outlet :scheduleEndButton, UIButton

  def viewDidLoad
    super

    # ensures picker shows the time it is handed
    @timePicker.timeZone = NSTimeZone.timeZoneWithName("UTC")

    # setting in IB doesn't allow 23:00 because of timezone shit
    @timePicker.maximumDate = Time.at(0).utc
    @timePicker.minimumDate = Time.at(23*3600 + 59*60 + 59).utc
    
    if @isStart
      @timePicker.date = @period.startTime || @period.schedule.end_time || FkP.wake_time
    else
      self.navigationItem.title = "End Time"
      @infoLabel.text = "Set the end time for this period"
      @timePicker.date = @period.endTime || @period.startTime || FkP.bed_time
    end

    @separatorLine = UIView.alloc.initWithFrame(CGRectZero)
    @separatorLine.backgroundColor = UIColor.lightGrayColor
    @jumpToTimeView.addSubview(@separatorLine)

    refreshTimeInterval
    @scheduleStartButton.enabled = false if @period.schedule.start_time.nil?
    @scheduleEndButton.enabled = false if @period.schedule.end_time.nil?

  end

  def viewWillLayoutSubviews
    @separatorLine.frame = [[0, 0], [@jumpToTimeView.frame.size.width, LINE_WIDTH]]
  end

  def done
    if @isStart
      @period.startTime = @timePicker.date.utc.strip_date
    else
      @period.endTime = @timePicker.date.utc.strip_date
    end

    self.navigationController.popViewControllerAnimated(true)
  end

  def refreshTimeInterval
    if @timePicker.date.min % 5 != 0 || FkP.fiveMinuteIntervals? == false
      @timePicker.minuteInterval = 1
    else
      @timePicker.minuteInterval = 5
    end
  end

  def jumpToTime(sender)
    case sender.tag
    when 0
      @timePicker.date = FkP.wake_time
    when 1
      @timePicker.date = @period.schedule.start_time
    when 2
      @timePicker.date = Time.at(12*3600).utc
    when 3
      @timePicker.date = @period.schedule.end_time
    when 4
      @timePicker.date = FkP.bed_time
    end

    refreshTimeInterval
  end

end