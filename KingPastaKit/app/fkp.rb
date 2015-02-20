class FkP < CDQManagedObject

  def self.status(clockRect)
    # check for method safety if Period.current doesn't exist, MUSTN'T CRASH!
    result = {}

    currentPeriod = Period.current
    nextPeriod = Period.next
    schedule = Schedule.today

    if schedule && schedule.periods.count > 0
      if currentPeriod
        result[:clock] = Clock.day(clockRect, schedule.all_periods.array, currentPeriod)
        result[:periodName] = currentPeriod.name
        result[:timeRemaining] = currentPeriod.time_remaining.length
      elsif !schedule.started? && !FkP.awake?
        result[:clock] = Clock.night(clockRect)
        result[:periodName] = "Night time"
        result[:timeRemaining] = FkP.time_until_wake.length
      elsif !schedule.started? && nextPeriod
        result[:clock] = Clock.morning(clockRect, schedule.all_periods.array)
        result[:periodName] = "Good morning!"
        result[:timeRemaining] = nextPeriod.time_until_start.length
      elsif nextPeriod
        result[:clock] = Clock.day(clockRect, schedule.all_periods.array, currentPeriod)
        result[:periodName] = "Free time"
        result[:timeRemaining] = nextPeriod.time_until_start.length
      elsif FkP.awake?
        result[:clock] = Clock.evening(clockRect, schedule.all_periods.array)
        result[:periodName] = "Schedule finished"
        result[:timeRemaining] = FkP.time_until_bed.length
      else
        result[:clock] = Clock.night(clockRect)
        result[:periodName] = "Night time"
        result[:timeRemaining] = FkP.time_until_wake.length
      end
    else
      result[:clock] = Clock.blank(clockRect)
      result[:periodName] = "Nothing Scheduled"
      result[:timeRemaining] = ""
    end

    result
  end

  def self.defaults
    @@defaults ||= FkP.first
  end

  def self.initialSetupComplete?
    defaults.initialSetupComplete.boolValue unless defaults.nil?
  end

  def self.registered_notifications?
    defaults.registeredNotifications.boolValue unless defaults.nil?
  end

  def self.wake_time
    defaults.wakeTime
  end

  def self.wake_time=(time)
    defaults.wakeTime = time
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
    defaults.bedTime
  end

  def self.bed_time=(time)
    defaults.bedTime = time
  end

  def self.time_until_bed
    Time.at(bed_time - Time.now.strip_seconds).utc
  end

  def self.awake?
    Time.now.strip_date > wake_time && Time.now.strip_date < bed_time
  end

  def self.register_notifications
    unless registered_notifications?
      notificationSettings = UIUserNotificationSettings.settingsForTypes(UIUserNotificationTypeAlert | UIUserNotificationTypeSound, categories: nil)
      UIApplication.sharedApplication.registerUserNotificationSettings(notificationSettings)
    end
  end

  def self.schedule_notifications
    cdq_background do
      UIApplication.sharedApplication.cancelAllLocalNotifications

      today = Time.today

      Day.each do |day|
        if schedule = day.schedule
          if schedule.shows_notifications?
            dayOffset = (7 + (day.dayOfWeek - today.day_of_week)) % 7

            schedule.periods.each do |period|
              notification = UILocalNotification.new
              notification.fireDate = today + (dayOffset * 86400) + period.startTime.to_i
              # notification.timeZone = ensure correct
              notification.repeatInterval = NSWeekCalendarUnit
              notification.alertBody = "#{period.name} has now started"
              notification.soundName = "bell.caf"

              UIApplication.sharedApplication.scheduleLocalNotification(notification)
            end
          end
        end
      end
    end
  end

  def self.log_notifications
    UIApplication.sharedApplication.scheduledLocalNotifications.each do |notification|
      NSLog "#{notification.fireDate.strftime('%e/%-m %a %k:%M')}  #{notification.alertBody.sub(' has now started', '')}"
    end

    true  # stops repl noise
  end

  def self.cdq_background(&block)
    # From CDQ Wiki documentation:
    # Create a new private queue context with the main context
    # as its parent, then pop it back off the stack.
    cdq.contexts.new(NSPrivateQueueConcurrencyType) do
      context = cdq.contexts.current

      # any work on a private context must be passed to performBlock
      context.performBlock(-> {
        cdq.contexts.push(context) do
          block.call
        end
      })
    end 
  end

end