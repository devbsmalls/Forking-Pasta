class CategoryColorMark < UIView

  attr_accessor :color

  def initWithFrame(frame)
    super
    self.backgroundColor = UIColor.clearColor

    self
  end

  def initWithCoder(aDecoder)
    super
    self.backgroundColor = UIColor.clearColor

    self
  end

  def color=(color)
    @color = color

    self.setNeedsDisplay
  end

  def drawRect(rect)
    unless @color.nil?
      context = UIGraphicsGetCurrentContext()
      CGContextSetFillColorWithColor(context, @color.CGColor)
      CGContextFillEllipseInRect(context, self.bounds)
    end
  end

end