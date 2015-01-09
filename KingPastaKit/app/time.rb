class Time

  def strip_date
    Time.at(self.hour*60*60 + self.min*60 + self.sec).utc
  end

  def strip_seconds
    Time.at(self.hour*60*60 + self.min*60).utc
  end

  def day_of_week
    # returns day of the week from 0 to 6 respecting user's first weekday
    # TODO: tidy up?
    @@firstWeekday ||= NSCalendar.currentCalendar.firstWeekday - 1
    (self.wday + (7 - @@firstWeekday)) % 7
  end

end