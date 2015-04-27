class InterfaceController < WKInterfaceController
  extend IB

  outlet :periodNameLabel, WKInterfaceLabel
  outlet :clockImage, WKInterfaceImage
  outlet :timeRemainingLabel, WKInterfaceLabel

  def initWithContext(context)
    super

    if WKInterfaceDevice.currentDevice.screenBounds.size.width < 156 
      @clockRect = CGRectMake(0, 0, 100, 100)
    else
      @clockRect = CGRectMake(0, 0, 120, 120)
    end

    return self
  end

  def willActivate
    FkP.setup
    @tick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "refresh", userInfo: nil, repeats: true) if @tick.nil?
    refresh
  end

  def didDeactivate
    unless @tick.nil?
      @tick.invalidate
      @tick = nil
    end
  end

  def refresh
    status = FkP.status(@clockRect)
    @clockImage.image = status[:clock]
    @periodNameLabel.text = status[:periodName]
    @timeRemainingLabel.text = status[:timeRemaining]
  end

end
