import Foundation
import RealmSwift

class Period: Object {
    dynamic var name: String = ""
    dynamic var startTime: NSTimeInterval = 0
    dynamic var endTime: NSTimeInterval = 0
    
    dynamic var day: Day?
    dynamic var category: Category?
    
    // TODO: This can be achieved better
    convenience init(name: String, startTime: NSTimeInterval, endTime: NSTimeInterval, day: Day, category: Category) {
        self.init()
        
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.day = day
        self.category = category
    }
    
    class func current() -> Period? {
        guard let periodsToday = Period.allToday() else { return nil }
        let time = Time.now()
        return periodsToday.filter("startTime <= %@", time).filter("endTime > %@", time).first
    }
    
    class func next() -> Period? {
        guard let periodsToday = Period.allToday() else { return nil }
        let time = Time.now()
        return periodsToday.filter("startTime > %@", time).first
    }
    
    class func allToday() -> Results<Period>? {
        guard let today = Day.today() else { return nil }
        return today.orderedPeriods()
    }
    
    class func allOnDayOfWeek(dayOfWeek: Int) -> Results<Period>? {
        guard let day = Day.getDayOfWeek(dayOfWeek) else { return nil }
        return day.orderedPeriods()
    }
    
    class func overlapWithStartTime(startTime: NSTimeInterval, endTime: NSTimeInterval, day: Day?, ignoringPeriod: Period?) -> Bool {
        guard let day = day else { return true }
        
        // TODO: is the last filter with block acceptable for Results<T>???
        let startDuring = day.periods.filter("startTime >= %@", startTime).filter("startTime < %@", endTime).filter { $0 != ignoringPeriod }
        let endDuring = day.periods.filter("endTime > %@", startTime).filter("endTime <= %@", endTime).filter { $0 != ignoringPeriod }
        let beforeToAfter = day.periods.filter("startTime <= %@", startTime).filter("endTime >= %@", endTime).filter { $0 != ignoringPeriod }
        
        return (startDuring.count + endDuring.count + beforeToAfter.count) > 0
    }
    
    enum OverlapType {
        case StartsAtEnd
        case StartsAfterEnd
        case Overlap
    }

    var timeRemaining: NSTimeInterval {
        return endTime - Time.now().approx
    }
    
    var timeUntilStart: NSTimeInterval {
        return startTime - Time.now().approx
    }
}