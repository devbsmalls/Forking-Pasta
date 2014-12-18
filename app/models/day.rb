class Day

  WAKEUP = Time.at(8*60*60 + 0*60 + 0).utc
  BEDTIME = Time.at(8*60*60 + 0*60 + 0).utc

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