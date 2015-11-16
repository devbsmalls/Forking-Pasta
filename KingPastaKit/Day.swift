import Foundation
import RealmSwift

class Day: Object {
    dynamic var name: String
    dynamic var dayOfWeek: Int
    
    // TODO: Reverse relationships?
    dynamic var schedule: Schedule?
    
    init(name: String, dayOfWeek: Int) {
        self.name = name
        self.dayOfWeek = dayOfWeek
        
        super.init()
    }

    required init() {
        fatalError("A Day object must be initialised with a name and day of week")
    }
    
    static let symbols = NSDateFormatter().weekdaySymbols.rotate(NSCalendar.currentCalendar().firstWeekday - 1)
    static let shortSymbols = NSDateFormatter().shortWeekdaySymbols.rotate(NSCalendar.currentCalendar().firstWeekday - 1)
    
    class func today() -> Day? {
        return FkP.realm.objects(Day).filter("dayOfWeek == %@", NSDate().dayOfWeek).first
    }
    
    class func tomorrow() -> Day? {
        return FkP.realm.objects(Day).filter("dayOfWeek == %@", NSDate().dateByAddingTimeInterval(86400).dayOfWeek).first
    }
    
    class func wday(wday: Int) -> Day? {
        return FkP.realm.objects(Day).filter("dayOfWeek == %@", wday).first
    }
}