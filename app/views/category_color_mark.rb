class CategoryColorMark < UIView

  attr_accessor :color

  def layoutSubviews
    self.layer.cornerRadius = self.bounds.size.width / 2
  end

  def color=(color)
    self.backgroundColor = color
  end

end