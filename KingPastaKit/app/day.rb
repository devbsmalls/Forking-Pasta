class Day

  WAKEUP = Time.at(9*60*60 + 0*60 + 0).utc    # so far only used in set time controller as default, rename?
  BEDTIME = Time.at(22*60*60 + 0*60 + 0).utc

  def self.starts
    Period.allToday.first.startTime
  end

  def self.ends
    Period.allToday[Period.allToday.count - 1].endTime  # why can't I use .last?!?!
  end

  def self.length
    ends - starts
  end

end