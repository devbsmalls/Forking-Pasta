import Foundation
import UIKit
import RealmSwift

class Category: Object {
    dynamic var name = ""
    dynamic var index = 0
    dynamic var colorIndex = 0
    
    var periods: Results<Period> {
        return FkP.realm.objects(Period).filter("category == %@", self)
    }
    
    class func forIndex(index: Int) -> Category {
        return FkP.realm.objects(Category).sorted("index")[index]
    }
    
    class var count: Int {
        return FkP.realm.objects(Category).count
    }
    
    // TODO: Use an enum of UIColor if possible?
    static let colors: [rawColor] = [.Blue, .Green, .Orange, .Red, .Pink, .Purple]
    
    enum rawColor {
        case Blue
        case Green
        case Orange
        case Red
        case Pink
        case Purple
        
        var value: UIColor {
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
    
    var color: UIColor {
        return Category.colors[colorIndex].value
    }
    
    var cgColor: CGColor {
        return color.CGColor
    }
}