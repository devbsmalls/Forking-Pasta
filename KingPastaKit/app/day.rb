class Day < CDQManagedObject

  def self.symbols
    @@daySymbols ||= NSDateFormatter.new.weekdaySymbols.rotate(NSCalendar.currentCalendar.firstWeekday - 1)
  end

  def self.shortSymbols
    @@shortDaySymbols ||= NSDateFormatter.new.shortWeekdaySymbols.rotate(NSCalendar.currentCalendar.firstWeekday - 1)
  end

  def self.today
    Day.where(:dayOfWeek).eq(Time.now.day_of_week).first
  end

  def self.tomorrow
    Day.where(:dayOfWeek).eq((Time.now + 86400).day_of_week).first
  end

  def self.wday(wday)
    Day.where(:dayOfWeek).eq(wday).first
  end

end