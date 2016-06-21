import Foundation

public extension NSDate {
    
    var minute: Int {
        let timeComponents = NSCalendar.currentCalendar().components(.Minute, fromDate: self)
        return timeComponents.minute
    }
    
    func time() -> NSTimeInterval {
        let components = NSCalendarUnit.Hour.union(.Minute).union(.Second)
        // let calendar = NSCalendar.currentCalendar()
        // calendar.timeZone = NSTimeZone(abbreviation: "UTC")!
        let timeComponents = NSCalendar.currentCalendar().components(components, fromDate: self)
        return Time.make(hours: timeComponents.hour, minutes: timeComponents.minute, seconds: timeComponents.second)
    }
    
    // TODO: Is this needed now with NSDateFormatter? Replaces stripSeconds
    func approxTime() -> NSTimeInterval {
        let components = NSCalendarUnit.Hour.union(.Minute)
        let timeComponents = NSCalendar.currentCalendar().components(components, fromDate: self)
        return Time.make(hours: timeComponents.hour, minutes: timeComponents.minute, seconds: 0)
    }
    
    var shortString: String {
        // TODO: Store formatter as a static constant
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .NoStyle
        formatter.timeZone = NSTimeZone.localTimeZone()
        return formatter.stringFromDate(self)
    }
    
    var dayOfWeek: Int {
        // returns day of the week from 0 to 6 respecting user's first weekday
        // TODO: firstWeekday as a class const
        let firstWeekday = NSCalendar.currentCalendar().firstWeekday - 1
        return (self.wday() + (7 - firstWeekday)) % 7
    }
    
    // mimics ruby #wday which returns day of week not relative to current calendar
    // TODO: Update to work relative to current calendar along with all references
    func wday() -> Int {
        let myCalendar = NSCalendar.currentCalendar()
        let myComponents = myCalendar.components(.Weekday, fromDate: self)
        return myComponents.weekday - 1
    }
    
    class func today() -> NSDate {
        return NSCalendar.currentCalendar().startOfDayForDate(NSDate())
    }
    
    class func tomorrow() -> NSDate {
        return NSCalendar.currentCalendar().startOfDayForDate(NSDate().dateByAddingTimeInterval(86400))
    }
    
    
    // TODO: Check for use of these - NSTimeInterval.date()
    class func make(hours hours: Int, minutes: Int, seconds: Int) -> NSDate {
        let timeComponents = NSDateComponents()
        timeComponents.hour = hours
        timeComponents.minute = minutes
        timeComponents.second = seconds
        return NSCalendar.currentCalendar().dateFromComponents(timeComponents)!
    }
    
    class func make(time: NSTimeInterval) -> NSDate {
        // return NSDate(timeIntervalSince1970: time)
        let hour = Int(time.hour)
        let minute = Int(time.minute)
        let second = Int(time.second)
        return make(hours: hour, minutes: minute, seconds: second)
    }
    
    // needed for complication timelines
    class func makeToday(time: NSTimeInterval) -> NSDate {
        return today().dateByAddingTimeInterval(time)
    }
}