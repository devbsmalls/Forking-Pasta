class WakeBedTimeController < UIViewController
  extend IB

  attr_accessor :isWake

  outlet :infoLabel, UILabel
  outlet :timePicker, UIDatePicker
  outlet :imageView, UIImageView

  def viewDidLoad
    super

    # ensures picker shows the time it is handed
    @timePicker.timeZone = NSTimeZone.timeZoneWithName("UTC")

    # setting in IB doesn't allow 23:00 because of timezone shit
    @timePicker.maximumDate = Time.at(0).utc
    @timePicker.minimumDate = Time.at(23*3600 + 59*60 + 59).utc
    
    if @isWake
      @timePicker.date = FkP.wake_time || Time.at(9*60*60 + 0*60 + 0).utc
      @imageView.image = UIImage.imageNamed("morning", inBundle: NSBundle.bundleWithIdentifier('uk.pixlwave.KingPastaKit'), compatibleWithTraitCollection: nil)
    else
      self.navigationItem.title = "Bed Time"
      @infoLabel.text = "What time do you usually go to bed?"
      @timePicker.date = FkP.bed_time || Time.at(22*60*60 + 30*60 + 0).utc
      @imageView.image = UIImage.imageNamed("evening", inBundle: NSBundle.bundleWithIdentifier('uk.pixlwave.KingPastaKit'), compatibleWithTraitCollection: nil)
    end

    refreshTimeInterval
  end

  def done

    if @isWake
      FkP.wake_time = @timePicker.date.utc.strip_date
    else
      FkP.bed_time = @timePicker.date.utc.strip_date
    end
    cdq.save

    self.navigationController.popViewControllerAnimated(true)
  end

  def refreshTimeInterval
    if @timePicker.date.min % 5 != 0 || FkP.fiveMinuteIntervals? == false
      @timePicker.minuteInterval = 1
    else
      @timePicker.minuteInterval = 5
    end
  end

end