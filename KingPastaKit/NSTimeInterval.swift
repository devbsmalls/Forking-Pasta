import Foundation


// hours: Int(self / 3600)
// minutes: Int((self % 3600) / 60)
// seconds: Int((self % 3600) % 60)

public extension NSTimeInterval {
    var hour: NSTimeInterval {
        return floor(self / 3600)
    }
    
    var minute: NSTimeInterval {
        return floor((self % 3600) / 60)
    }
    
    var second: NSTimeInterval {
        return floor((self % 3600) % 60)
    }
    
    var approx: NSTimeInterval {
        return self - self.second
    }
    
    var shortString: String {
        return self.date().shortString
    }
    
    var lengthString: String {
        // TODO: Check against TimeZones
        let mins = Int(self.minute)
        let hours = Int(self.hour)
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
    
    func date() -> NSDate {
        return NSDate.make(self)
    }
    
    // needed for complication timelines
    func dateToday() -> NSDate {
        return NSDate.makeToday(self)
    }
    
}

class Time {
    class func now() -> NSTimeInterval {
        return NSDate().time()
    }
    
    class func make(hours hours: Int, minutes: Int, seconds: Int) -> NSTimeInterval {
        return NSTimeInterval(3600 * hours + 60 * minutes + seconds)
    }
}