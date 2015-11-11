import Foundation
import RealmSwift

class FkP {
    static let realm = try! Realm()
    
    static let appGroupContainer = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.uk.pixlwave.ForkingPasta")!.path
    
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
}