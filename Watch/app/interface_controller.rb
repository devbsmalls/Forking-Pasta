class InterfaceController < WKInterfaceController
  extend IB

  outlet :periodNameLabel, WKInterfaceLabel
  outlet :clockImage, WKInterfaceImage
  outlet :timeRemainingLabel, WKInterfaceLabel

  def initWithContext(context)
    super

    @clockRect = CGRectMake(0, 0, 100, 100)

    return self
  end

  def willActivate
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
    # needs safety methods that don't crash _AT ALL_ if Period.current doesn't exist, etc etc etc
    currentPeriod = Period.current
    nextPeriod = Period.next
    schedule = Schedule.today

    if schedule
      if currentPeriod
        @clockImage.image = Clock.day(@clockRect)
        @periodNameLabel.text = currentPeriod.name
        @timeRemainingLabel.text = currentPeriod.time_remaining.length
      elsif !schedule.started? && !schedule.awake?
        @clockImage.image = Clock.night(@clockRect)
        @periodNameLabel.text = "Night time"
        @timeRemainingLabel.text = schedule.time_until_wake.length
      elsif !schedule.started? && nextPeriod
        @clockImage.image = Clock.day(@clockRect)
        @periodNameLabel.text = "Good morning!"
        @timeRemainingLabel.text = nextPeriod.time_until_start.length
      elsif nextPeriod
        @clockImage.image = Clock.day(@clockRect)
        @periodNameLabel.text = "Free time"
        @timeRemainingLabel.text = nextPeriod.time_until_start.length
      elsif schedule.awake?
        @clockImage.image = Clock.day(@clockRect)
        @periodNameLabel.text = "Schedule finished"
        @timeRemainingLabel.text = schedule.time_until_bed.length
      else
        @clockImage.image = Clock.night(@clockRect)
        @periodNameLabel.text = "Night time"
        @timeRemainingLabel.text = schedule.time_until_wake.length
      end
    else
      @clockImage.image = Clock.day(@clockRect)
      @periodNameLabel.text = "Nothing Scheduled"
      @timeRemainingLabel.text = ""
    end
  end

end
