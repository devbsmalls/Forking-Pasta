class Time

  def strip_date
    Time.at(self.hour*60*60 + self.min*60 + self.sec).utc
  end

  def strip_seconds
    Time.at(self.hour*60*60 + self.min*60).utc
  end

end