class Period < CDQManagedObject

  def self.current
    time = Time.now.strip_date

    if periods_today = Period.all_today then periods_today.where(:startTime).le(time).where(:endTime).gt(time).first end
  end

  def self.next
    time = Time.now.strip_date

    if periods_today = Period.all_today then periods_today.where(:startTime).gt(time).first end
  end

  def self.all_today
    if schedule_today = Schedule.today then schedule_today.all_periods end
  end

  def self.all_on_wday(wday)
    if schedule_wday = Schedule.on_wday(wday) then schedule_wday.all_periods end
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
    before_to_after = self.schedule.periods.where(:startTime).le(self.startTime).where(:endTime).ge(self.endTime).reject { |p| p == self}
    
    (start_during.count + end_during.count + before_to_after.count) > 0
  end

end