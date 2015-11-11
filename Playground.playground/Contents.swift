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