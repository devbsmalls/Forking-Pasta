class Category

  # GREEN = UIColor.colorWithRed(0.757, green:1.000, blue:0.557, alpha:1.0).CGColor
  # BLUE = UIColor.colorWithRed(0.557, green:0.910, blue:1.000, alpha:1.0).CGColor
  # PURPLE = UIColor.colorWithRed(0.753, green:0.557, blue:1.000, alpha:1.0).CGColor
  # RED = UIColor.colorWithRed(1.000, green:0.565, blue:0.557, alpha:1.0).CGColor
  # ORANGE = UIColor.colorWithRed(1.000, green:0.859, blue:0.557, alpha:1.0).CGColor

  @@colors = {
    home: UIColor.colorWithRed(0.557, green:0.910, blue:1.000, alpha:1.0),
    work: UIColor.colorWithRed(0.757, green:1.000, blue:0.557, alpha:1.0),
    misc: UIColor.colorWithRed(1.000, green:0.859, blue:0.557, alpha:1.0)
  }

  def self.symbols
    [:home, :work, :misc]
  end

  def self.getColorForName(name)
    @@colors[name.to_sym]
  end

  def self.getCGColorForName(name)
    getColorForName(name).CGColor
  end

end