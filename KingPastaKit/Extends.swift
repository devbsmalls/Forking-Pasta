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

/// Global shortcut for NSUserDefaults.standardUserDefaults()

public let SharedDefaults = NSUserDefaults(suiteName: "group.uk.pixlwave.ForkingPasta") ?? NSUserDefaults.standardUserDefaults()