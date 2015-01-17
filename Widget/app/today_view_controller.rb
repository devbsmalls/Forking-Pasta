class TodayViewController < UIViewController

  def viewDidLoad
    super

    @clockImageView = UIImageView.alloc.init
    @clockImageView.image = UIImage.imageNamed("clock_test")
    @clockImageView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(@clockImageView)

    @periodNameLabel = UILabel.alloc.init
    @periodNameLabel.text = "Forking Pasta!"
    @periodNameLabel.font = UIFont.systemFontOfSize(20.0)
    @periodNameLabel.textColor = UIColor.whiteColor
    @periodNameLabel.textAlignment = NSTextAlignmentLeft
    @periodNameLabel.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(@periodNameLabel)

    @timeRemainingLabel = UILabel.alloc.init
    @timeRemainingLabel.text = "FkP"
    @timeRemainingLabel.textColor = UIColor.whiteColor
    @timeRemainingLabel.textAlignment = NSTextAlignmentLeft
    @timeRemainingLabel.numberOfLines = 2
    @timeRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(@timeRemainingLabel)

    widgetViews = {"clockImage" => @clockImageView, "periodLabel" => @periodNameLabel, "timeLabel" => @timeRemainingLabel}
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[clockImage(120)]-20-[periodLabel]-|", options: 0, metrics: nil, views: widgetViews))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[clockImage]-20-[timeLabel]-|", options: 0, metrics: nil, views: widgetViews))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[clockImage(120)]|", options: 0, metrics: nil, views: widgetViews))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[periodLabel]-[timeLabel(==periodLabel)]-|", options: 0, metrics: nil, views: widgetViews))

    self.preferredContentSize = CGSizeMake(320, 120)
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

    @periodNameLabel.text = "Free time"
    @timeRemainingLabel.text = "n/a"

    if currentPeriod
      @periodNameLabel.text = currentPeriod.name
      @timeRemainingLabel.text = currentPeriod.time_remaining.length
    elsif nextPeriod
      @timeRemainingLabel.text = nextPeriod.time_until_start.length
    elsif Day.awake?
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
