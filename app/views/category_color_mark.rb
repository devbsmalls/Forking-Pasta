class CategoryColorMark < UIView

  attr_accessor :color

  def color=(color)
    @color = color
    self.backgroundColor = UIColor.clearColor
  end

  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, @color.CGColor)
    CGContextFillEllipseInRect(context, self.bounds)
  end

end