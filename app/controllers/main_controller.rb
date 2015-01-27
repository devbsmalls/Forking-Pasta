class MainController < UIViewController
  extend IB

  outlet :watchView, UIView
  outlet :clockImageView, UIImageView
  outlet :periodNameLabel, UILabel
  outlet :timeRemainingLabel, UILabel

  def viewDidLoad
    super

    watchView.layer.cornerRadius = 10
    watchView.layer.borderColor = UIColor.blackColor
    watchView.layer.borderWidth = 1
  end

  def viewWillAppear(animated)
    super

    @tick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "redraw", userInfo: nil, repeats: true) if @tick.nil?
    @tick.fireDate = Time.now.round + 1   # ensures the timer fires on the second
  end

  def viewDidAppear(animated)
    super

    redraw
  end

  def viewWillDisappear(animated)
    super

    unless @tick.nil?
      @tick.invalidate
      @tick = nil
    end
  end

  def redraw
    currentPeriod = Period.current
    nextPeriod = Period.next
    schedule = Schedule.today

    if schedule
      if currentPeriod
        @clockImageView.image = Clock.day(@clockImageView.bounds)
        @periodNameLabel.text = currentPeriod.name
        @timeRemainingLabel.text = currentPeriod.time_remaining.length
      elsif !schedule.started? && !schedule.awake?
        @clockImageView.image = Clock.night(@clockImageView.bounds)
        @periodNameLabel.text = "Night time"
        @timeRemainingLabel.text = schedule.time_until_wake.length
      elsif !schedule.started? && nextPeriod
        @clockImageView.image = Clock.day(@clockImageView.bounds)
        @periodNameLabel.text = "Good morning!"
        @timeRemainingLabel.text = nextPeriod.time_until_start.length
      elsif nextPeriod
        @clockImageView.image = Clock.day(@clockImageView.bounds)
        @periodNameLabel.text = "Free time"
        @timeRemainingLabel.text = nextPeriod.time_until_start.length
      elsif schedule.awake?
        @clockImageView.image = Clock.day(@clockImageView.bounds)
        @periodNameLabel.text = "Schedule finished"
        @timeRemainingLabel.text = schedule.time_until_bed.length
      else
        @clockImageView.image = Clock.night(@clockImageView.bounds)
        @periodNameLabel.text = "Night time"
        @timeRemainingLabel.text = schedule.time_until_wake.length
      end
    else
      @clockImageView.image = Clock.day(@clockImageView.bounds)
      @periodNameLabel.text = "Nothing Scheduled"
      @timeRemainingLabel.text = ""
    end
  end

end