class PeriodColorMark < UIView

  attr_accessor :color

  def color=(color)
    @color = color

    self.setNeedsDisplay
  end

  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, @color.CGColor)
    CGContextFillRect(context, self.bounds)
  end

end