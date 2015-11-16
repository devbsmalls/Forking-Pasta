import UIKit
import RealmSwift

struct Status {
    var clock: UIImage?
    var periodName: String?
    var timeRemaining: String?
}

class FkP {
    static let realm = try! Realm()
    
    static let appGroupContainer = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.uk.pixlwave.ForkingPasta")!.path
    
    class func status(clockRect: CGRect) -> Status {
        var result = Status()
        
        let currentPeriod = Period.current()
        let nextPeriod = Period.next()
        let schedule = Schedule.today()
        
        if let schedule = schedule where schedule.periods.count > 0 {
            if let currentPeriod = currentPeriod {
                result.clock = Clock.day(clockRect, periods: Array(schedule.orderedPeriods()), currentPeriod: currentPeriod)
                result.periodName = currentPeriod.name
                result.timeRemaining = currentPeriod.timeRemaining.length()
            } else if !schedule.hasStarted && !FkP.isAwake {
                result.clock = Clock.night(clockRect)
                result.periodName = "Night time"
                result.timeRemaining = FkP.timeUntilWake.length()
            } else if let nextPeriod = nextPeriod where !schedule.hasStarted {
                result.clock = Clock.morning(clockRect, periods: Array(schedule.orderedPeriods()))
                result.periodName = "\(nextPeriod.name) in"
                result.timeRemaining = nextPeriod.timeUntilStart.length()
            } else if let nextPeriod = nextPeriod {
                // TODO: Don't pass a Period? for current??
                result.clock = Clock.day(clockRect, periods: Array(schedule.orderedPeriods()), currentPeriod: currentPeriod)
                result.periodName = "Free time"
                result.timeRemaining = nextPeriod.timeUntilStart.length()
            } else if FkP.isAwake {
                result.clock = Clock.evening(clockRect, periods: Array(schedule.orderedPeriods()))
                result.periodName = "Bedtime in"
                result.timeRemaining = FkP.timeUntilBed.length()
            } else {
                result.clock = Clock.night(clockRect)
                result.periodName = "Night time"
                result.timeRemaining = FkP.timeUntilWake.length()
            }
        } else {
            if FkP.isAwake {
                result.clock = Clock.blank(clockRect)
                result.periodName = "Free time"
                result.timeRemaining = "Nothing scheduled"
            } else {
                result.clock = Clock.night(clockRect)
                result.periodName = "Night time"
                result.timeRemaining = FkP.timeUntilWake.length()
            }
        }
        
        return result
    }
    
    // TODO: update to modern Defaults
    class var isInitialSetupComplete: Bool {
        return Defaults["initialSetupComplete"].boolValue
    }
    
    class var hasSeenGettingStarted: Bool {
        get {
            return Defaults["hasSeenGettingStarted"].boolValue
        }
        set {
            Defaults["hasSeenGettingStarted"] = newValue
        }
    }
    
    class var hasRegisteredNotifications: Bool {
        get {
            return Defaults["registeredNotifications"].boolValue
        }
        set {
            Defaults["registeredNotifications"] = newValue
        }
    }
    
    class var useFiveMinuteIntervals: Bool {
        get {
            return Defaults["fiveMinuteIntervals"].bool ?? true
        }
        set {
            Defaults["fiveMinuteIntervals"] = newValue
        }
    }
    
    class var wakeTime: NSDate {
        get {
            return Defaults["wakeTime"].date ?? NSDate.make(hours: 8, minutes: 0, seconds: 0) // TODO: .utc
        }
        set {
            Defaults["wakeTime"] = newValue
        }
    }
    
    class var timeUntilWake: NSDate {
        let time = NSDate().stripDate()
        
        if time.compare(wakeTime) == .OrderedAscending { // <
            return NSDate(timeIntervalSince1970: wakeTime.timeIntervalSinceDate(time)) // TODO: .utc
        } else {
            return NSDate(timeIntervalSince1970: wakeTime.timeIntervalSinceDate(time) + 86400) // TODO: .utc
        }
    }
    
    class var bedTime: NSDate {
        get {
            return Defaults["bedTime"].date ?? NSDate.make(hours: 22, minutes: 30, seconds: 0)
        }
        set {
            Defaults["bedTime"] = newValue
        }
    }
    
    class var timeUntilBed: NSDate {
        return NSDate(timeIntervalSince1970: bedTime.timeIntervalSinceDate(NSDate().stripSeconds())) // TODO: .utc
    }
    
    class var isAwake: Bool {
        return (NSDate().stripDate().compare(wakeTime) == .OrderedDescending) && (NSDate().stripDate().compare(bedTime) == .OrderedAscending)
    }
    
    class func registerNotifications() {
        if !hasRegisteredNotifications {
            // TODO: Check settings conversion has worked
            let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert.union(.Sound), categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            hasRegisteredNotifications = true
        }
    }
    
    class func scheduleNotifications() {
        // TODO: Dispatch::Queue.concurrent.async do
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            
            let today = NSDate.today()
            
            for day in realm.objects(Day) {
                if let schedule = day.schedule {
                    if schedule.showsNotifications {
                        let dayOffset = NSTimeInterval((7 + (day.dayOfWeek - today.dayOfWeek)) % 7)
                        
                        for period in schedule.periods {
                            let notification = UILocalNotification()
                            notification.fireDate = today.dateByAddingTimeInterval(dayOffset * 86400).dateByAddingTimeInterval(period.startTime.timeIntervalSince1970)
                            // notification.timeZone = TODO: ensure correct
                            notification.repeatInterval = .WeekOfYear   // TODO: ensure this replaces NSWeekCalendarUnit
                            notification.alertBody = "\(period.name) has now started"
                            notification.soundName = "chime.caf"
                            
                            UIApplication.sharedApplication().scheduleLocalNotification(notification)
                        }
                    }
                }
            }
        // end
    }
    
    class func logNotifications() {
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for notification in notifications {
                // notification.fireDate.strftime('%e/%-m %a %k:%M')    // TODO: Convert this or remove?
                let name = notification.alertBody?.stringByReplacingOccurrencesOfString(" has now started", withString: "")
                NSLog("\(notification.fireDate)  \(name)")
            }
        }
    }
    
}