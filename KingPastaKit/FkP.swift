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
        let day = Day.today()
        
        if let day = day where day.periods.count > 0 {
            if let currentPeriod = currentPeriod {
                result.clock = Clock.day(clockRect, periods: Array(day.orderedPeriods()), currentPeriod: currentPeriod)
                result.periodName = currentPeriod.name
                result.timeRemaining = currentPeriod.timeRemaining.lengthString
            } else if !day.hasStarted && !FkP.isAwake {
                result.clock = Clock.night(clockRect)
                result.periodName = "Night time"
                result.timeRemaining = FkP.timeUntilWake.lengthString
            } else if let nextPeriod = nextPeriod where !day.hasStarted {
                result.clock = Clock.morning(clockRect, periods: Array(day.orderedPeriods()))
                result.periodName = "\(nextPeriod.name) in"
                result.timeRemaining = nextPeriod.timeUntilStart.lengthString
            } else if let nextPeriod = nextPeriod {
                // TODO: Don't pass a Period? for current??
                result.clock = Clock.day(clockRect, periods: Array(day.orderedPeriods()), currentPeriod: currentPeriod)
                result.periodName = "Free time"
                result.timeRemaining = nextPeriod.timeUntilStart.lengthString
            } else if FkP.isAwake {
                result.clock = Clock.evening(clockRect, periods: Array(day.orderedPeriods()))
                result.periodName = "Bedtime in"
                result.timeRemaining = FkP.timeUntilBed.lengthString
            } else {
                result.clock = Clock.night(clockRect)
                result.periodName = "Night time"
                result.timeRemaining = FkP.timeUntilWake.lengthString
            }
        } else {
            if FkP.isAwake {
                result.clock = Clock.blank(clockRect)
                result.periodName = "Free time"
                result.timeRemaining = "Nothing scheduled"
            } else {
                result.clock = Clock.night(clockRect)
                result.periodName = "Night time"
                result.timeRemaining = FkP.timeUntilWake.lengthString
            }
        }
        
        return result
    }
    
    // TODO: update to modern Defaults
    class var isInitialSetupComplete: Bool {
        get {
            return Defaults["isInitialSetupComplete"].boolValue
        }
        set {
            Defaults["isInitialSetupComplete"] = newValue
        }
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
            return Defaults["hasRegisteredNotifications"].boolValue
        }
        set {
            Defaults["hasRegisteredNotifications"] = newValue
        }
    }
    
    class var useFiveMinuteIntervals: Bool {
        get {
            return Defaults["useFiveMinuteIntervals"].bool ?? true
        }
        set {
            Defaults["useFiveMinuteIntervals"] = newValue
        }
    }
    
    class var wakeTime: NSTimeInterval {
        get {
            return Defaults["wakeTime"].double ?? Time.make(hours: 8, minutes: 0, seconds: 0)
        }
        set {
            Defaults["wakeTime"] = newValue
        }
    }
    
    class var timeUntilWake: NSTimeInterval {
        let time = Time.now()
        
        if time < wakeTime {
            return wakeTime - time
        } else {
            return wakeTime - time + 86400
        }
    }
    
    class var bedTime: NSTimeInterval {
        get {
            return Defaults["bedTime"].double ?? Time.make(hours: 22, minutes: 30, seconds: 0)
        }
        set {
            Defaults["bedTime"] = newValue
        }
    }
    
    class var timeUntilBed: NSTimeInterval {
        return bedTime - Time.now().approx
    }
    
    class var isAwake: Bool {
        return Time.now() > wakeTime && Time.now() < bedTime
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
                if day.showsNotifications {
                    let dayOffset = NSTimeInterval((7 + (day.dayOfWeek - today.dayOfWeek)) % 7)
                    
                    for period in day.periods {
                        let notification = UILocalNotification()
                        notification.fireDate = today.dateByAddingTimeInterval(dayOffset * 86400).dateByAddingTimeInterval(period.startTime)
                        // notification.timeZone = TODO: ensure correct
                        notification.repeatInterval = .WeekOfYear   // TODO: ensure this replaces NSWeekCalendarUnit
                        notification.alertBody = "\(period.name) has now started"
                        notification.soundName = "chime.caf"
                        
                        UIApplication.sharedApplication().scheduleLocalNotification(notification)
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