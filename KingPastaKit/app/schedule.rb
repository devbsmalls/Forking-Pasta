class Schedule < CDQManagedObject

  def all_periods
    self.periods.sort_by(:startTime)
  end

  def days_string
    case days.count
    when 0
      ""
    when 1
      days.first.name
    when 2
      days_arr = days.sort_by(:dayOfWeek).array
      days_arr = days_arr.reverse if days_arr[0].dayOfWeek == 0 && days_arr[1].dayOfWeek == 6   # puts days 0 & 6 in running order
      days_arr.map { |day| day.name }.join(" & ")
    else
      days_arr = days.sort_by(:dayOfWeek).array
      days_arr.take(days_arr.count - 1).map { |day| Day.shortSymbols[day.dayOfWeek] }.join(", ") + " & #{Day.shortSymbols[days_arr.last.dayOfWeek]}"
    end
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