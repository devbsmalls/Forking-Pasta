class Period < CDQManagedObject

  def self.current
    time = Time.now.strip_date

    Period.where(Day.today).eq(true).where(:startTime).le(time).where(:endTime).gt(time).first
  end

  def self.next
    time = Time.now.strip_date

    # this won't work for the day after next - fix but beware of NO events or only 1 block of events (just iterate 1 week)
    next_period = Period.where(Day.today).eq(true).where(:startTime).gt(time).sort_by(:startTime).first
    if next_period.nil?
      next_period = Period.where(Day.tomorrow).eq(true).sort_by(:startTime).first
    end

    next_period
  end

  def self.allToday
    Period.where(Day.today).eq(true).sort_by(:startTime)
  end

  def self.allOn(day)
    Period.where(day.downcase.to_sym).eq(true).sort_by(:startTime)
  end


  #### predicate methods ####

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