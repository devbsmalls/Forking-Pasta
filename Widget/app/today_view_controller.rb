class TodayViewController < UIViewController
  extend IB

  outlet :clockImageView, UIImageView
  outlet :periodNameLabel, UILabel
  outlet :timeRemainingLabel, UILabel

  def viewDidLoad
    super

    @periodNameLabel.text = "Loading..."
    @timeRemainingLabel.text = ""
  end

  def viewDidAppear(animated)
    super

    @tick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "refresh", userInfo: nil, repeats: true) if @tick.nil?
  end

  def viewWillDisappear(animated)
    super

    unless @tick.nil?
      @tick.invalidate
      @tick = nil
    end
  end

  def didReceiveMemoryWarning
    super
    # Dispose of any resources that can be recreated.
  end

  def refresh
    # needs safety methods that don't crash _AT ALL_ if Period.current doesn't exist, etc etc etc
    # wants to go into KingPastaKit Period.current.remaining
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

  def widgetPerformUpdateWithCompletionHandler(completionHandler)
    refresh

    completionHandler.call(NCUpdateResultNewData)
  end

  def widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets)
    UIEdgeInsetsMake(15, defaultMarginInsets.left, 15, defaultMarginInsets.right)
  end

end
