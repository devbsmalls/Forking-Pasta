import UIKit
import RealmSwift

public class TimeZone: Object {
    public dynamic var name = ""
    public dynamic var index = 0
    public dynamic var colorIndex = 0
    
    var periods: Results<Period> {
        return FkP.realm.objects(Period).filter("timeZone == %@", self)
    }
    
    public class func forIndex(index: Int) -> TimeZone {
        return FkP.realm.objects(TimeZone).sorted("index")[index]
    }
    
    public class var count: Int {
        return FkP.realm.objects(TimeZone).count
    }
    
    // TODO: Use an enum of UIColor if possible?
    public static let colors: [rawColor] = [.Blue, .Green, .Orange, .Red, .Pink, .Purple]
    
    public enum rawColor {
        case Blue
        case Green
        case Orange
        case Red
        case Pink
        case Purple
        
        public var value: UIColor {
            switch self {
            case Blue:
                return UIColor(red: 0.557, green: 0.910, blue: 1.000, alpha: 1.0)
            case Green:
                return UIColor(red: 0.757, green: 1.000, blue: 0.557, alpha: 1.0)
            case Orange:
                return UIColor(red: 1.000, green: 0.859, blue: 0.557, alpha: 1.0)
            case Red:
                return UIColor(red: 1.000, green: 0.565, blue: 0.557, alpha: 1.0)
            case Pink:
                return UIColor(red: 1.000, green: 0.557, blue: 0.905, alpha: 1.0)
            case Purple:
                return UIColor(red: 0.753, green: 0.557, blue: 1.000, alpha: 1.0)
            }
        }
    }
    
    static let freeColor = UIColor.darkGrayColor()
    static let nightColor = UIColor(red: 0.0, green: 0.1, blue: 0.3, alpha: 1.0)
    
    public var color: UIColor {
        return TimeZone.colors[colorIndex].value
    }
    
    var cgColor: CGColor {
        return color.CGColor
    }
}