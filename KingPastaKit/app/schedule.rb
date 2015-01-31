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

  def started?
    return false if all_periods.count < 1
    Time.now.strip_date > all_periods.array.first.startTime
  end

  def starts
    self.all_periods.array.first.startTime  # this won't work if there are any unsaved objects that don't have a start time defined
  end

  def ends
    self.all_periods.array.last.endTime  # can't use .last without .array - Also, array helps reliable objects while editing
  end

  def length
    ends - starts
  end

  def self.today
    Day.today.schedule if Day.today
  end

  def self.tomorrow
    Day.tomorrow.schedule if Day.tomorrow
  end

  def self.on_wday(wday)
    Day.wday(wday).schedule if Day.wday(wday)
  end

  def time_until_wake
    time = Time.now.strip_seconds

    if time < wakeTime
      Time.at(wakeTime - time).utc
    elsif Schedule.tomorrow
      Time.at((Schedule.tomorrow.wakeTime + 86400) - time).utc
    else
      Time.at((wakeTime + 86400) - time).utc
    end
  end

  def time_until_bed
    Time.at(bedTime - Time.now.strip_seconds).utc
  end

  def awake?
    Time.now.strip_date > wakeTime && Time.now.strip_date < bedTime
  end

end