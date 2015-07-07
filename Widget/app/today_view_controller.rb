class TodayViewController < UIViewController
  extend IB

  outlet :clockImageView, UIImageView
  outlet :periodNameLabel, UILabel
  outlet :timeRemainingLabel, UILabel

  def viewDidLoad
    super

    FkP.setup

    @periodNameLabel.text = " "
    @timeRemainingLabel.text = " "
  end

  def viewDidAppear(animated)
    super

    if FkP.initialSetupComplete?
      @tick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "refresh", userInfo: nil, repeats: true) if @tick.nil?
    else
      nothing_scheduled
    end
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
    status = FkP.status(@clockImageView.bounds)
    @clockImageView.image = status[:clock]
    @periodNameLabel.text = status[:periodName]
    @timeRemainingLabel.text = status[:timeRemaining]
  end

  def nothing_scheduled
    @clockImageView.image = Clock.blank(@clockRect)
    @periodNameLabel.text = "Free time"
    @timeRemainingLabel.text = "Nothing scheduled"
  end

  def widgetPerformUpdateWithCompletionHandler(completionHandler)
    FkP.setup

    if FkP.initialSetupComplete?
      refresh
    else
      nothing_scheduled
    end

    completionHandler.call(NCUpdateResultNewData)
  end

  def widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets)
    # defaults: top: 0, left: 47, bottom: 39, right: 0)
    UIEdgeInsetsMake(10, defaultMarginInsets.left, 10, 0)
  end

end
