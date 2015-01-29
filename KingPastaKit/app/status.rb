class Status

  def self.update(clockRect)
    # check for method safety if Period.current doesn't exist, MUSTN'T CRASH!

    result = {}

    currentPeriod = Period.current
    nextPeriod = Period.next
    schedule = Schedule.today

    if schedule
      if currentPeriod
        result[:clock] = Clock.day(clockRect)
        result[:periodName] = currentPeriod.name
        result[:timeRemaining] = currentPeriod.time_remaining.length
      elsif !schedule.started? && !schedule.awake?
        result[:clock] = Clock.night(clockRect)
        result[:periodName] = "Night time"
        result[:timeRemaining] = schedule.time_until_wake.length
      elsif !schedule.started? && nextPeriod
        result[:clock] = Clock.day(clockRect)
        result[:periodName] = "Good morning!"
        result[:timeRemaining] = nextPeriod.time_until_start.length
      elsif nextPeriod
        result[:clock] = Clock.day(clockRect)
        result[:periodName] = "Free time"
        result[:timeRemaining] = nextPeriod.time_until_start.length
      elsif schedule.awake?
        result[:clock] = Clock.day(clockRect)
        result[:periodName] = "Schedule finished"
        result[:timeRemaining] = schedule.time_until_bed.length
      else
        result[:clock] = Clock.night(clockRect)
        result[:periodName] = "Night time"
        result[:timeRemaining] = schedule.time_until_wake.length
      end
    else
      result[:clock] = Clock.day(clockRect)
      result[:periodName] = "Nothing Scheduled"
      result[:timeRemaining] = ""
    end

    result
  end

end