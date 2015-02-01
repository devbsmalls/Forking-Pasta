class FkP < CDQManagedObject

  def self.status
    # 
  end

  def self.initialSetupComplete?
    FkP.first.initialSetupComplete unless FkP.first.nil?
  end

  def self.wake_time
    FkP.first.wakeTime
  end

  def self.wake_time=(time)
    FkP.first.wakeTime = time
  end

  def self.time_until_wake
    time = Time.now.strip_seconds

    if time < wake_time
      Time.at(wake_time - time).utc
    else
      Time.at((wake_time + 86400) - time).utc
    end
  end

  def self.bed_time
    FkP.first.bedTime
  end

  def self.bed_time=(time)
    FkP.first.bedTime = time
  end

  def self.time_until_bed
    Time.at(bed_time - Time.now.strip_seconds).utc
  end

  def self.awake?
    Time.now.strip_date > wake_time && Time.now.strip_date < bed_time
  end

end