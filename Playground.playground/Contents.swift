//: Playground - noun: a place where people can play

import Cocoa


extension Array {
    func rotate(index: Int) -> Array {
        var slice = self[index..<self.count]
        slice += self[0..<index]
        return Array(slice)
    }
}

NSDateFormatter().weekdaySymbols
NSDateFormatter().weekdaySymbols.rotate(NSCalendar.currentCalendar().firstWeekday - 1)
NSCalendar.currentCalendar().weekdaySymbols
NSDateFormatter().calendar == NSCalendar.currentCalendar()
NSDateFormatter().calendar == NSCalendar(calendarIdentifier: "UK")

let todayDate = NSDate().dateByAddingTimeInterval(60*60*24)
let myCalendar = NSCalendar.currentCalendar()
let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
let weekDay = myComponents.weekday

let components = NSCalendarUnit.Hour.union(NSCalendarUnit.Minute).union(NSCalendarUnit.Second)
let time = NSCalendar.currentCalendar().components(components, fromDate: NSDate())
let date = NSCalendar.currentCalendar().dateFromComponents(time)

func info() -> [String: AnyObject] {
    var dict = [String: AnyObject]()
    dict["Hello"] = 1
    dict["World"] = "Hey there!"
    return dict
}

let update = info()
update["Hello"]

extension NSTimeInterval {
    var approx: NSTimeInterval {
        return self - (self % 3600 % 60)
    }
}

let time2 = NSTimeInterval(3600 * 12 + 60 * 36 + 20)

Int(time2 / 3600)
Int((time2 % 3600) / 60)
Int(time2 % 3600 % 60)

let approx = time2.approx
Int(approx % 3600 % 60)

4 % 5

// TODO: These aren't needed anymore
func make(hours hours: Int, minutes: Int, seconds: Int) -> NSDate {
    let timeComponents = NSDateComponents()
    timeComponents.hour = hours
    timeComponents.minute = minutes
    timeComponents.second = seconds
    return NSCalendar.currentCalendar().dateFromComponents(timeComponents)! // TODO: .utc
}

func make(time: NSTimeInterval) -> NSDate {
    return NSDate(timeIntervalSince1970: time)
}

let testd = make(hours: 16, minutes: 50, seconds: 00)
