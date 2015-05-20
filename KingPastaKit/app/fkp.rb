class FkP
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include MotionModel::Validatable

  columns :initialSetupComplete => { type: :boolean, default: false },
          :hasSeenGettingStarted => { type: :boolean, default: false },
          :registeredNotifications => { type: :boolean, default: false },
          :fiveMinuteIntervals => { type: :boolean, default: true },
          :wakeTime => { type: :date, default: Time.at(8*60*60 + 0*60 + 0).utc },
          :bedTime => { type: :date, default: Time.at(22*60*60 + 30*60 + 0).utc}

  # validates :initialSetupComplete, :presence => true
  # validates :registeredNotifications, :presence => true
  # validates :fiveMinuteIntervals, :presence => true
  # validates :wakeTime, :presence => true
  # validates :bedTime, :presence => true

  @@is_setup = false

  def self.setup
    destroy if @@is_setup

    dir = app_group_container   # lazy load in method
    Schedule.deserialize_from_file('schedule.dat', dir)
    Day.deserialize_from_file('day.dat', dir)
    Period.deserialize_from_file('period.dat', dir)
    Category.deserialize_from_file('category.dat', dir)
    FkP.deserialize_from_file('fkp.dat', dir)

    @@is_setup = true
  end

  def self.save
    dir = app_group_container   # lazy load in method
    Schedule.serialize_to_file('schedule.dat', dir)
    Day.serialize_to_file('day.dat', dir)
    Period.serialize_to_file('period.dat', dir)
    Category.serialize_to_file('category.dat', dir)
    FkP.serialize_to_file('fkp.dat', dir)
  end

  def self.destroy
    Schedule.destroy_all
    Day.destroy_all
    Period.destroy_all
    Category.destroy_all
    FkP.destroy_all
  end

  def self.app_group_container
    if (UIDevice.currentDevice.model =~ /simulator/i).nil?  # device
      dir = NSFileManager.defaultManager.containerURLForSecurityApplicationGroupIdentifier("group.uk.pixlwave.ForkingPasta").path
    else   # simulator workaround with hard coded path
      dev_container = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).last.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent
      dir = dev_container.stringByAppendingPathComponent("Shared").stringByAppendingPathComponent("AppGroup").stringByAppendingPathComponent("697E2EAA-A35A-4BFA-939B-B1CF6C84C5D2")
      Dir.mkdir(dir) unless Dir.exist?(dir)
      
      dir
    end
  end

  def self.status(clockRect)
    # check for method safety if Period.current doesn't exist, MUSTN'T CRASH!
    result = {}

    currentPeriod = Period.current
    nextPeriod = Period.next
    schedule = Schedule.today

    if schedule && schedule.periods.count > 0
      if currentPeriod
        result[:clock] = Clock.day(clockRect, schedule.ordered_periods.array, currentPeriod)
        result[:periodName] = currentPeriod.name
        result[:timeRemaining] = currentPeriod.time_remaining.length
      elsif !schedule.started? && !FkP.awake?
        result[:clock] = Clock.night(clockRect)
        result[:periodName] = "Night time"
        result[:timeRemaining] = FkP.time_until_wake.length
      elsif !schedule.started? && nextPeriod
        result[:clock] = Clock.morning(clockRect, schedule.ordered_periods.array)
        result[:periodName] = "#{nextPeriod.name} in"
        result[:timeRemaining] = nextPeriod.time_until_start.length
      elsif nextPeriod
        result[:clock] = Clock.day(clockRect, schedule.ordered_periods.array, currentPeriod)
        result[:periodName] = "Free time"
        result[:timeRemaining] = nextPeriod.time_until_start.length
      elsif FkP.awake?
        result[:clock] = Clock.evening(clockRect, schedule.ordered_periods.array)
        result[:periodName] = "Bedtime in"
        result[:timeRemaining] = FkP.time_until_bed.length
      else
        result[:clock] = Clock.night(clockRect)
        result[:periodName] = "Night time"
        result[:timeRemaining] = FkP.time_until_wake.length
      end
    else
      if FkP.awake?
        result[:clock] = Clock.blank(clockRect)
        result[:periodName] = "Free time"
        result[:timeRemaining] = "Nothing scheduled"
      else
        result[:clock] = Clock.night(clockRect)
        result[:periodName] = "Night time"
        result[:timeRemaining] = FkP.time_until_wake.length
      end
    end

    result
  end

  def self.defaults
    @@defaults ||= FkP.first
  end

  def self.initialSetupComplete?
    defaults.initialSetupComplete unless defaults.nil?
  end

  def self.getting_started_seen?
    defaults.hasSeenGettingStarted unless defaults.nil?
  end

  def self.getting_started_seen=(value)
    defaults.hasSeenGettingStarted = value unless defaults.nil?
  end

  def self.registered_notifications?
    defaults.registeredNotifications unless defaults.nil?
  end

  def self.registered_notifications=(value)
    defaults.registeredNotifications = value unless defaults.nil?
  end

  def self.fiveMinuteIntervals?
    defaults.fiveMinuteIntervals unless defaults.nil?
  end

  def self.fiveMinuteIntervals=(value)
    defaults.fiveMinuteIntervals = value
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
      self.registered_notifications = true
      save
    end
  end

  def self.schedule_notifications
    Dispatch::Queue.concurrent.async do
      UIApplication.sharedApplication.cancelAllLocalNotifications

      today = Time.today

      Day.each do |day|
        if schedule = day.schedule
          if schedule.shows_notifications?
            dayOffset = (7 + (day.dayOfWeek - today.day_of_week)) % 7

            schedule.periods.each do |period|
              notification = UILocalNotification.new
              notification.fireDate = today + (dayOffset * 86400) + period.startTime.to_i
              # notification.timeZone = TODO: ensure correct
              notification.repeatInterval = NSWeekCalendarUnit
              notification.alertBody = "#{period.name} has now started"
              notification.soundName = "chime.caf"

              UIApplication.sharedApplication.scheduleLocalNotification(notification)
            end

            unless schedule.end_time.nil?
              notification = UILocalNotification.new
              notification.fireDate = today + (dayOffset * 86400) + schedule.end_time.to_i
              # notification.timeZone = TODO: ensure correct
              notification.repeatInterval = NSWeekCalendarUnit
              notification.alertBody = "#{schedule.name} has now finished"
              notification.soundName = "chime.caf"

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

end