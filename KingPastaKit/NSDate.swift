import Foundation

extension NSDate {
    
    func stripDate() -> NSDate {
        let components = NSCalendarUnit.Hour.union(NSCalendarUnit.Minute).union(NSCalendarUnit.Second)
        let timeComponents = NSCalendar.currentCalendar().components(components, fromDate: self)
        return NSCalendar.currentCalendar().dateFromComponents(timeComponents)! // TODO: .utc
    }
    
    // TODO: Is this needed now with NSDateFormatter?
    func stripSeconds() -> NSDate {
        let components = NSCalendarUnit.Hour.union(NSCalendarUnit.Minute)
        let timeComponents = NSCalendar.currentCalendar().components(components, fromDate: self)
        return NSCalendar.currentCalendar().dateFromComponents(timeComponents)! // TODO: .utc
    }
    
    func shortString() -> String {
        // TODO: Store formatter as a static constant
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .NoStyle
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return formatter.stringFromDate(self)
    }
    
    func length() -> String {
        // TODO: Check against TimeZones
        let hours = NSCalendar.currentCalendar().components(.Hour, fromDate: self).hour
        let mins = NSCalendar.currentCalendar().components(.Minute, fromDate: self).minute
        var timeRemaining = String()
        
        if mins == 1 {
            timeRemaining = "\(mins) minute"
        } else {
            timeRemaining = "\(mins) minutes"
        }
        
        if hours == 1 {
            timeRemaining = "\(hours) hour \(timeRemaining)"
        } else if hours > 1 {
            timeRemaining = "\(hours) hours \(timeRemaining)"
        }
        
        return timeRemaining
    }
    
    func dayOfWeek() -> Int {
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
    
    class func make(hours hours: Int, minutes: Int, seconds: Int) -> NSDate {
        let timeComponents = NSDateComponents()
        timeComponents.hour = hours
        timeComponents.minute = minutes
        timeComponents.second = seconds
        return NSCalendar.currentCalendar().dateFromComponents(timeComponents)! // TODO: .utc
    }
}