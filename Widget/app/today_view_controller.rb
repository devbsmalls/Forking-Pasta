class TodayViewController < UIViewController
  extend IB

  outlet :clockImageView, UIImageView
  outlet :periodNameLabel, UILabel
  outlet :timeRemainingLabel, UILabel

  def viewDidLoad
    super

    # self.preferredContentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 120)
  end

  def didReceiveMemoryWarning
    super
    # Dispose of any resources that can be recreated.
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

  def refresh
    @clockImageView.image = Clock.draw(@clockImageView.bounds)

    # needs safety methods that don't crash _AT ALL_ if Period.current doesn't exist, etc etc etc
    # wants to go into KingPastaKit Period.current.remaining
    currentPeriod = Period.current
    nextPeriod = Period.next

    if currentPeriod
      @periodNameLabel.text = currentPeriod.name
      @timeRemainingLabel.text = currentPeriod.time_remaining.length
    elsif nextPeriod
      @periodNameLabel.text = "Free time"
      @timeRemainingLabel.text = nextPeriod.time_until_start.length
    elsif Day.awake?
      @periodNameLabel.text = "Free time"
      @timeRemainingLabel.text = Day.time_until_bed.length
    else
      @periodNameLabel.text = "Night Time"
      @timeRemainingLabel.text = Day.time_until_wake.length
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
