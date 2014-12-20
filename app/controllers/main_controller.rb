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
    currentPeriod = Period.currentPeriod
    nextPeriod = Period.nextPeriod

    @periodNameLabel.text = "Free time"
    @timeRemainingLabel.text = "n/a"

    if currentPeriod
      @periodNameLabel.text = currentPeriod.name
      hours = Time.at(currentPeriod.endTime - Time.now.strip_seconds).utc.hour
      mins = Time.at(currentPeriod.endTime - Time.now.strip_seconds).utc.min

      if mins == 1
        minsString = "#{mins} minute"
      else
        minsString = "#{mins} minutes"
      end

      if hours == 1
        timeRemaining = "#{hours} hour #{minsString}"
      elsif hours > 1
        timeRemaining = "#{hours} hours #{minsString}"
      else
        timeRemaining = minsString
      end

      @timeRemainingLabel.text = timeRemaining
    elsif nextPeriod  # this covers same and next day
      hours = Time.at(nextPeriod.startTime - Time.now.strip_seconds).utc.hour
      mins = Time.at(nextPeriod.startTime - Time.now.strip_seconds).utc.min

      if mins == 1
        minsString = "#{mins} minute"
      else
        minsString = "#{mins} minutes"
      end

      if hours == 1
        timeRemaining = "#{hours} hour #{minsString}"
      elsif hours > 1
        timeRemaining = "#{hours} hours #{minsString}"
      else
        timeRemaining = minsString
      end

      @timeRemainingLabel.text = timeRemaining
    end

    @clockImageView.image = Clock.draw(@clockImageView.bounds)
  end

end