class Category < CDQManagedObject

  # GREEN = UIColor.colorWithRed(0.757, green:1.000, blue:0.557, alpha:1.0).CGColor
  # BLUE = UIColor.colorWithRed(0.557, green:0.910, blue:1.000, alpha:1.0).CGColor
  # PURPLE = UIColor.colorWithRed(0.753, green:0.557, blue:1.000, alpha:1.0).CGColor
  # RED = UIColor.colorWithRed(1.000, green:0.565, blue:0.557, alpha:1.0).CGColor
  # ORANGE = UIColor.colorWithRed(1.000, green:0.859, blue:0.557, alpha:1.0).CGColor

  # Category.new(name: "Home", index: 0, color: UIColor.colorWithRed(0.557, green:0.910, blue:1.000, alpha:1.0))
  # Category.new(name: "Work", index: 1, color: UIColor.colorWithRed(0.757, green:1.000, blue:0.557, alpha:1.0))
  # Category.new(name: "Misc", index: 2, color: UIColor.colorWithRed(1.000, green:0.859, blue:0.557, alpha:1.0))

  def cgColor
    color.CGColor
  end

end