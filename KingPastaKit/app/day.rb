class Day < CDQManagedObject

  WAKEUP = Time.at(9*60*60 + 0*60 + 0).utc    # so far only used in set time controller as default, rename?
  BEDTIME = Time.at(22*60*60 + 0*60 + 0).utc

  def self.today
    Day.where(:dayOfWeek).eq(Time.now.wday).first
  end

  def self.tomorrow
    Day.where(:dayOfWeek).eq((Time.now + 86400).wday).first
  end

  def self.wday(wday)
    Day.where(:dayOfWeek).eq(wday).first
  end

end