class Period < CDQManagedObject

  def self.current
    time = Time.now.strip_date

    Period.all_today.where(:startTime).le(time).where(:endTime).gt(time).first if Period.all_today
  end

  def self.next
    time = Time.now.strip_date

    Period.all_today.where(:startTime).gt(time).first if Period.all_today
  end

  def self.all_today
    Schedule.today.all_periods if Schedule.today
  end

  def self.all_on_wday(wday)
    Schedule.on_wday(wday).all_periods if Schedule.on_wday(wday)
  end

  def time_remaining
    Time.at(self.endTime - Time.now.strip_seconds).utc
  end

  def time_until_start
    Time.at(self.startTime - Time.now.strip_seconds).utc
  end

  def has_overlap?
    start_during = self.schedule.periods.where(:startTime).ge(startTime).where(:startTime).lt(endTime).reject { |p| p == self}
    end_during = self.schedule.periods.where(:endTime).gt(startTime).where(:endTime).le(endTime).reject { |p| p == self}
    
    (start_during.count + end_during.count) > 0
  end

end