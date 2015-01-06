class Schedule < CDQManagedObject

  def all_periods
    self.periods.sort_by(:startTime)
  end

  def starts
    self.all_periods.first.startTime
  end

  def ends
    self.all_periods[self.periods.count - 1].endTime  # why can't I use .last?!?! (because you're not getting an array here)
  end

  def length
    ends - starts
  end

  def self.today
    Day.today.schedule if Day.today
  end

  def self.on_wday(wday)
    Day.wday(wday).schedule if Day.wday(wday)
  end

end