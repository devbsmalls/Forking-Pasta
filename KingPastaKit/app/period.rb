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

    Period.where(day).eq(true).where(:startTime).gt(time).sort_by(:startTime).first
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