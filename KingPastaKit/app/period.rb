class Period < CDQManagedObject

  def self.currentPeriod
    now = Time.now
    day = now.strftime('%A').downcase.to_sym  # this won't work for other languages
    time = now.strip_date

    Period.where(day).eq(true).where(:startTime).le(time).where(:endTime).gt(time).first
  end

  def self.nextPeriod
    now = Time.now
    day = now.strftime('%A').downcase.to_sym  # this won't work for other languages
    time = now.strip_date

    # this won't work for the day after next - fix but beware of NO events or only 1 block of events (just iterate 1 week)
    nextP = Period.where(day).eq(true).where(:startTime).gt(time).sort_by(:startTime).first
    if nextP.nil?
      tomorrow = (Time.now + 24*3600).strftime('%A').downcase.to_sym  # this won't work for other languages
      nextP = Period.where(tomorrow).eq(true).sort_by(:startTime).first
    end

    nextP
  end

  def self.allToday
    now = Time.now
    day = now.strftime('%A').downcase.to_sym  # this won't work for other languages

    Period.where(day).eq(true).sort_by(:startTime)
  end

  def self.allOn(day)
    Period.where(day.downcase.to_sym).eq(true).sort_by(:startTime)
  end

  def self.define_predicate_methods
    methods = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

    methods.each do |method|
      define_method("#{method}?") do
        value = self.send(method)
        value.nil? ? false : value.boolValue
      end
    end
  end

  define_predicate_methods

end