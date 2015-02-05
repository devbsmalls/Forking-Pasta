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
    status = FkP.status(@clockImageView.bounds)
    @clockImageView.image = status[:clock]
    @periodNameLabel.text = status[:periodName]
    @timeRemainingLabel.text = status[:timeRemaining]
  end

end