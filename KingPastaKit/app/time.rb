class Time

  def strip_date
    Time.at(self.hour*60*60 + self.min*60 + self.sec).utc
  end

  def strip_seconds
    Time.at(self.hour*60*60 + self.min*60).utc
  end

  def length
    hours = self.hour
    mins = self.min

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
  end

  def day_of_week
    # returns day of the week from 0 to 6 respecting user's first weekday
    # TODO: tidy up?
    @@firstWeekday ||= NSCalendar.currentCalendar.firstWeekday - 1
    (self.wday + (7 - @@firstWeekday)) % 7
  end

  def self.today
    now = Time.now
    Time.new(now.year, now.month, now.day)
  end

end