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

  def widgetPerformUpdateWithCompletionHandler(completionHandler)
    @clockImageView.image = Clock.draw(@clockImageView.bounds)
    @periodNameLabel.text = "Period #{Time.now.hour}"
    @timeRemainingLabel.text = "#{Time.now.min} minutes"

    completionHandler.call(NCUpdateResultNewData)
  end

  def widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets)
    UIEdgeInsetsMake(15, defaultMarginInsets.left, 15, defaultMarginInsets.right)
  end

end
