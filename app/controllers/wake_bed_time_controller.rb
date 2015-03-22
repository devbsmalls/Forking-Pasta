class WakeBedTimeController < UIViewController
  extend IB

  attr_accessor :isWake

  LINE_WIDTH = 1 / UIScreen.mainScreen.scale

  outlet :infoLabel, UILabel
  outlet :timePicker, UIDatePicker
  outlet :bottomView, UIVisualEffectView
  outlet :embossImageView, UIImageView

  def viewDidLoad
    super

    # ensures picker shows the time it is handed
    @timePicker.timeZone = NSTimeZone.timeZoneWithName("UTC")

    # setting in IB doesn't allow 23:00 because of timezone shit
    @timePicker.maximumDate = Time.at(0).utc
    @timePicker.minimumDate = Time.at(23*3600 + 59*60 + 59).utc
    
    if @isWake
      @timePicker.date = FkP.wake_time || Time.at(9*60*60 + 0*60 + 0).utc
    else
      self.navigationItem.title = "Bed Time"
      @infoLabel.text = "What time do you usually go to bed?"
      @timePicker.date = FkP.bed_time || Time.at(22*60*60 + 30*60 + 0).utc
    end

    @separatorLine = UIView.alloc.initWithFrame(CGRectZero)
    @separatorLine.backgroundColor = UIColor.lightGrayColor
    @bottomView.addSubview(@separatorLine)
    
    case UIScreen.mainScreen.bounds.size.width
    when 375, 667
      @embossImageView.image = UIImage.imageNamed("icon_emboss_4.7")
    when 414, 736
      @embossImageView.image = UIImage.imageNamed("icon_emboss_5.5")
    end

    refreshTimeInterval
  end

  def viewWillLayoutSubviews
    @separatorLine.frame = [[0, 0], [@bottomView.frame.size.width, LINE_WIDTH]]
  end

  def done
    if @isWake
      FkP.wake_time = @timePicker.date.utc.strip_date
    else
      FkP.bed_time = @timePicker.date.utc.strip_date
    end
    FkP.save

    self.navigationController.popViewControllerAnimated(true)
  end

  def refreshTimeInterval
    if @timePicker.date.min % 5 != 0 || FkP.fiveMinuteIntervals? == false
      @timePicker.minuteInterval = 1
    else
      @timePicker.minuteInterval = 5
    end
  end

end