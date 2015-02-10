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
    status = FkP.status(@clockImageView.bounds)
    @clockImageView.image = status[:clock]
    @periodNameLabel.text = status[:periodName]
    @timeRemainingLabel.text = status[:timeRemaining]
  end

  def widgetPerformUpdateWithCompletionHandler(completionHandler)
    refresh

    completionHandler.call(NCUpdateResultNewData)
  end

  def widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets)
    # defaults: top: 0, left: 47, bottom: 39, right: 0)
    UIEdgeInsetsMake(10, defaultMarginInsets.left, 10, 0)
  end

end
