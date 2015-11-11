import Foundation
import RealmSwift

class Schedule: Object {
    dynamic var name = ""
    dynamic var showsNotifications = false
    
    var days: Results<Day> {
        return FkP.realm.objects(Day).filter("schedule == %@", self)
    }
    var periods: Results<Period> {
        return FkP.realm.objects(Period).filter("schedule == %@", self)
    }
    
    func orderedPeriods() -> Results<Period> {
        return periods.sorted("startTime")
    }
    
    func daysString() -> String {
        switch days.count {
        case 0:
            return " "       // space stops detailTextLabel collapsing to a size of 0 in the ScheduleController
        case 1:
            return days.first!.name
        case 2:
            var daysArray = Array(days.sorted("dayOfWeek"))
            // puts days 0 & 6 in running order
            if daysArray[0].dayOfWeek == 0 && daysArray[1].dayOfWeek == 6 {
                daysArray = daysArray.reverse()
            }
            return daysArray.map { $0.name }.joinWithSeparator(" & ")
        default:
            let daysArray = Array(days.sorted("dayOfWeek"))
            return daysArray.prefix(daysArray.count - 1).map { Day.shortSymbols[$0.dayOfWeek] }.joinWithSeparator(", ") + " & \(Day.shortSymbols[daysArray.last!.dayOfWeek])"
        }
    }
    var hasStarted: Bool {
        if orderedPeriods().count < 1 {
            return false
        } else if let firstPeriod = orderedPeriods().first {
            return NSDate().stripDate().compare(firstPeriod.startTime) == .OrderedDescending // >
        }
        // TODO: Better swift flow?
        return false
    }
    
    func startTime() -> NSDate? {
        switch periods.count {
        case 0:
            return nil
        case 1:
            return periods.first!.startTime
        default:
            // rejects unsaved objects which don't have a start time
            return orderedPeriods().filter { $0.startTime != nil }.first?.startTime
        }
    }
    
    func endTime() -> NSDate? {
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
    
    func length() -> NSDate? {
        guard let endTime = endTime(), startTime = startTime() else { return nil }
        return NSDate(timeIntervalSince1970: endTime.timeIntervalSinceDate(startTime))
    }
    
    class func today() -> Schedule? {
        guard let dayToday = Day.today() else { return nil }
        return dayToday.schedule
    }
    
    class func tomorrow() -> Schedule? {
        guard let dayTomorrow = Day.tomorrow() else { return nil }
        return dayTomorrow.schedule
    }
    
    class func onWday(wday: Int) -> Schedule? {
        guard let dayWday = Day.wday(wday) else { return nil }
        return dayWday.schedule
    }
}
