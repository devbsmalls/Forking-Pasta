import UIKit

class PeriodColorMark: UIView {
    
    var color: UIColor? {
        didSet { setNeedsDisplay() }
    }
    
    override func drawRect(rect: CGRect) {
        if let color = color {
            let context = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillRect(context, self.bounds)
        }
    }
    
}