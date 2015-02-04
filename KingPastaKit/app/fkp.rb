class FkP < CDQManagedObject

  def self.status
    # 
  end

  def self.initialSetupComplete?
    FkP.first.initialSetupComplete.boolValue unless FkP.first.nil?
  end

  def self.registered_notifications?
    FkP.first.registeredNotifications.boolValue unless FkP.first.nil?
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

  def self.register_notifications
    unless registered_notifications?
      notificationSettings = UIUserNotificationSettings.settingsForTypes(UIUserNotificationTypeAlert | UIUserNotificationTypeSound, categories: nil)
      UIApplication.sharedApplication.registerUserNotificationSettings(notificationSettings)
    end
  end

  def self.schedule_notifications
    Dispatch::Queue.main.async do
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

end