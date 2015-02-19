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

  def shows_notifications?
    self.showsNotifications.boolValue
  end

  def shows_notifications=(bool)
    self.showsNotifications = bool
  end

  def self.today
    if day_today = Day.today then day_today.schedule end
  end

  def self.tomorrow
    if day_tomorrow = Day.tomorrow then day_tomorrow.schedule end
  end

  def self.on_wday(wday)
    if day_wday = Day.wday(wday) then day_wday.schedule end
  end

end