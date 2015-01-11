class Period < CDQManagedObject

  def self.current
    time = Time.now.strip_date

    Period.all_today.where(:startTime).le(time).where(:endTime).gt(time).first if Period.all_today
  end

  def self.next
    time = Time.now.strip_date

    # this won't work for the day after next - fix but beware of NO events or only 1 block of events (just iterate 1 week)
    next_period = Period.all_today.where(:startTime).gt(time).first if Period.all_today
    if next_period.nil?
      schedule = Day.tomorrow.schedule
      next_period = schedule.all_periods.first if schedule
    end

    next_period
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

end