import Foundation
import RealmSwift

class Period: Object {
    dynamic var name: String
    dynamic var startTime: NSDate
    dynamic var endTime: NSDate
    
    dynamic var schedule: Schedule?
    dynamic var category: Category
    
    init(name: String, startTime: NSDate, endTime: NSDate, category: Category) {
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        
        super.init()
    }

    required init() {
        fatalError("A Period must be initialised with a name, start time and end time")
    }
    
    class func current() -> Period? {
        guard let periodsToday = Period.allToday() else { return nil }
        let time = NSDate().stripDate()
        return periodsToday.filter("startTime <= %@", time).filter("endTime > %@", time).first
    }
    
    class func next() -> Period? {
        guard let periodsToday = Period.allToday() else { return nil }
        let time = NSDate().stripDate()
        return periodsToday.filter("startTime > %@", time).first
    }
    
    class func allToday() -> Results<Period>? {
        guard let scheduleToday = Schedule.today() else { return nil }
        return scheduleToday.orderedPeriods()
    }
    
    class func allOnWday(wday: Int) -> Results<Period>? {
        guard let scheduleWday = Schedule.onWday(wday) else { return nil }
        return scheduleWday.orderedPeriods()
    }
    
    class func overlapWithStartTime(startTime: NSDate, endTime: NSDate, schedule: Schedule, ignoringPeriod: Period) -> Bool {
        // TODO: is the last filter with block acceptable for Results<T>???
        let startDuring = schedule.periods.filter("startTime >= %@", startTime).filter("startTime < %@", endTime).filter { $0 != ignoringPeriod }
        let endDuring = schedule.periods.filter("endTime > %@", startTime).filter("endTime <= %@", endTime).filter { $0 != ignoringPeriod }
        let beforeToAfter = schedule.periods.filter("startTime <= %@", startTime).filter("endTime >= %@", endTime).filter { $0 != ignoringPeriod }
        
        return (startDuring.count + endDuring.count + beforeToAfter.count) > 0
    }

    func timeRemaining() -> NSDate {
        return NSDate(timeIntervalSince1970: endTime.timeIntervalSinceDate(NSDate().stripSeconds())) // TODO: .utc
    }
    
    func timeUntilStart() -> NSDate {
        return NSDate(timeIntervalSince1970: startTime.timeIntervalSinceDate(NSDate().stripSeconds())) // TODO: .utc
    }
}