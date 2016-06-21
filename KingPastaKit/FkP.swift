import UIKit
import RealmSwift

public struct Status {
    public var clock: UIImage?
    public var periodName: String?
    public var timeRemaining: String?
}

public class FkP {
    public static var realm: Realm {
        return try! Realm(configuration: realmConfig)
    }
    
    // TODO: Tidy up to use realmURL in realmConfig and ?? to default location
    public static let realmURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.uk.pixlwave.ForkingPasta")?.URLByAppendingPathComponent("ForkingPasta.realm")
    
    public static let appGroupContainer = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.uk.pixlwave.ForkingPasta")!
    static let realmConfig = Realm.Configuration(fileURL: appGroupContainer.URLByAppendingPathComponent("ForkingPasta.realm"))
    
    public class func status(clockRect: CGRect) -> Status {
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
    public class var isInitialSetupComplete: Bool {
        get {
            return SharedDefaults["isInitialSetupComplete"].boolValue
        }
        set {
            SharedDefaults["isInitialSetupComplete"] = newValue
        }
    }
    
    public class var hasSeenGettingStarted: Bool {
        get {
            return SharedDefaults["hasSeenGettingStarted"].boolValue
        }
        set {
            SharedDefaults["hasSeenGettingStarted"] = newValue
        }
    }
    
    public class var hasRegisteredNotifications: Bool {
        get {
            return SharedDefaults["hasRegisteredNotifications"].boolValue
        }
        set {
            SharedDefaults["hasRegisteredNotifications"] = newValue
        }
    }
    
    public class var useFiveMinuteIntervals: Bool {
        get {
            return SharedDefaults["useFiveMinuteIntervals"].bool ?? true
        }
        set {
            SharedDefaults["useFiveMinuteIntervals"] = newValue
        }
    }
    
    public class var wakeTime: NSTimeInterval {
        get {
            return SharedDefaults["wakeTime"].double ?? Time.make(hours: 8, minutes: 0, seconds: 0)
        }
        set {
            SharedDefaults["wakeTime"] = newValue
        }
    }
    
    public class var timeUntilWake: NSTimeInterval {
        let time = Time.now()
        
        if time < wakeTime {
            return wakeTime - time
        } else {
            return wakeTime - time + 86400
        }
    }
    
    public class var bedTime: NSTimeInterval {
        get {
            return SharedDefaults["bedTime"].double ?? Time.make(hours: 22, minutes: 30, seconds: 0)
        }
        set {
            SharedDefaults["bedTime"] = newValue
        }
    }
    
    public class var timeUntilBed: NSTimeInterval {
        return bedTime - Time.now().approx
    }
    
    public class var isAwake: Bool {
        return Time.now() > wakeTime && Time.now() < bedTime
    }
        
}