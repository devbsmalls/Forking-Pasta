import UIKit

class CategoryColorMark: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }
    
    var color: UIColor? {
        didSet { setNeedsDisplay() }
    }
    
    override func drawRect(rect: CGRect) {
        if let color = color {
            let context = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillEllipseInRect(context, bounds)
        }
    }
    
}