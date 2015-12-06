import UIKit

extension UILabel {
    public func monospaceDigits() {
        // TODO: read font weight from existing font
        font = UIFont.monospacedDigitSystemFontOfSize(font.pointSize, weight: UIFontWeightRegular)
    }
}