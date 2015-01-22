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

    @tick = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:"redraw", userInfo:nil, repeats:true) if @tick.nil?
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

    if currentPeriod
      @periodNameLabel.text = currentPeriod.name
      @timeRemainingLabel.text = currentPeriod.time_remaining.length
    elsif nextPeriod
      @periodNameLabel.text = "Free time"
      @timeRemainingLabel.text = nextPeriod.time_until_start.length
    elsif Day.awake?
      @periodNameLabel.text = "Schedule finished"
      @timeRemainingLabel.text = Day.time_until_bed.length
    else
      @periodNameLabel.text = "Night time"
      @timeRemainingLabel.text = Day.time_until_wake.length
    end

    @clockImageView.image = Clock.draw(@clockImageView.bounds)
  end

end