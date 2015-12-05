import Foundation
import RealmSwift

public class Day: Object {
    public dynamic var name: String = ""
    public dynamic var dayOfWeek: Int = 0
    public dynamic var showsNotifications = false
    
    // TODO: Reverse relationships?
    public var periods: Results<Period> {
        return FkP.realm.objects(Period).filter("day == %@", self)
    }
    
    convenience init(name: String, dayOfWeek: Int) {
        self.init()
        
        self.name = name
        self.dayOfWeek = dayOfWeek
    }
    
    public func orderedPeriods() -> Results<Period> {
        return periods.sorted("startTime")
    }
    
    var hasStarted: Bool {
        if orderedPeriods().count < 1 {
            return false
        } else if let firstPeriod = orderedPeriods().first {
            return Time.now() > firstPeriod.startTime
        }
        // TODO: Better swift flow?
        return false
    }
    
    public var startTime: NSTimeInterval? {
        switch periods.count {
        case 0:
            return nil
        case 1:
            return periods.first?.startTime
        default:
            // rejects unsaved objects which don't have a start time
            return orderedPeriods().filter { $0.startTime != nil }.first?.startTime
        }
    }
    
    public var endTime: NSTimeInterval? {
        switch periods.count {
        case 0:
            return nil
        case 1:
            return periods.first?.endTime
        default:
            // RubyMotion: array helps reliable objects while editing and allows for .last
            return orderedPeriods().filter { $0.startTime != nil }.last?.endTime
        }
    }
    
    var length: NSTimeInterval? {
        guard let endTime = endTime, startTime = startTime else { return nil }
        return endTime - startTime
    }
    
    public func clear() {
        let realm = FkP.realm
        try! realm.write {
            for period in self.periods { realm.delete(period) }
        }
    }
    
    public static let symbols = NSDateFormatter().weekdaySymbols.rotate(NSCalendar.currentCalendar().firstWeekday - 1)
    static let shortSymbols = NSDateFormatter().shortWeekdaySymbols.rotate(NSCalendar.currentCalendar().firstWeekday - 1)
    
    class func today() -> Day? {
        return FkP.realm.objects(Day).filter("dayOfWeek == %@", NSDate().dayOfWeek).first
    }
    
    class func tomorrow() -> Day? {
        // TODO: make a tomorrow method on NSDate?
        return FkP.realm.objects(Day).filter("dayOfWeek == %@", NSDate().dateByAddingTimeInterval(86400).dayOfWeek).first
    }
    
    class func getDayOfWeek(dayOfWeek: Int) -> Day? {
        return FkP.realm.objects(Day).filter("dayOfWeek == %@", dayOfWeek).first
    }
}