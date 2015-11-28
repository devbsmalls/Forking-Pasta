import Foundation
import RealmSwift

extension Array {
    func rotate(index: Int) -> Array {
        var slice = self[index..<self.count]
        slice += self[0..<index]
        return Array(slice)
    }
}

extension String {
    func beginsWith (str: String) -> Bool {
        if let range = self.rangeOfString(str) {
            return range.startIndex == self.startIndex
        }
        return false
    }
    
    func endsWith (str: String) -> Bool {
        if let range = self.rangeOfString(str, options:NSStringCompareOptions.BackwardsSearch) {
            return range.endIndex == self.endIndex
        }
        return false
    }
}

extension UIImage {
    public class func named(name: String, inBundle bundle: NSBundle?) -> UIImage? {
        #if os(ios)
            return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
        #else
            if let bundle = bundle, url = bundle.URLForResource(name, withExtension: "png"), let data = NSData(contentsOfURL: url) {
                return UIImage(data: data)
            } else {
                return UIImage(named: name)
            }
        #endif
    }
}

/// Global shortcut for NSUserDefaults.standardUserDefaults()

public let SharedDefaults = NSUserDefaults(suiteName: "group.uk.pixlwave.ForkingPasta") ?? NSUserDefaults.standardUserDefaults()