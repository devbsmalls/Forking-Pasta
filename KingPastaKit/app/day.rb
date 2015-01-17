class Day < CDQManagedObject

  @@wake_time = Time.at(8*60*60 + 0*60 + 0).utc    # so far only used in set time controller as default, rename?
  @@bed_time = Time.at(22*60*60 + 30*60 + 0).utc

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

  def self.wake_time
    @@wake_time
  end

  def self.wake_time=(time)
    @@wake_time = time
  end

  def self.time_until_wake
    time = Time.now.strip_date

    if time < wake_time
      Time.at(wake_time - time).utc
    else
      Time.at((wake_time + 86400) - time).utc
    end
  end

  def self.bed_time
    @@bed_time
  end

  def self.bed_time=(time)
    @@bed_time = time
  end

  def self.time_until_bed
    Time.at(bed_time - Time.now.strip_date).utc
  end

  def self.awake?
    Time.now.strip_date < bed_time
  end

end