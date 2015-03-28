class Category
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include MotionModel::Validatable

  columns :name => :string,
          :index => :integer,
          :colorIndex => :integer

  # validates :name, :presence => true
  # validates :index, :presence => true
  # validates :colorIndex, :presence => true

  has_many :periods

  COLORS = [
    { name: "Blue", value: UIColor.colorWithRed(0.557, green:0.910, blue:1.000, alpha:1.0) },
    { name: "Green", value: UIColor.colorWithRed(0.757, green:1.000, blue:0.557, alpha:1.0) },
    { name: "Orange", value: UIColor.colorWithRed(1.000, green:0.859, blue:0.557, alpha:1.0) },
    { name: "Red", value: UIColor.colorWithRed(1.000, green:0.565, blue:0.557, alpha:1.0) },
    { name: "Purple", value: UIColor.colorWithRed(0.753, green:0.557, blue:1.000, alpha:1.0) }
  ]

  FREE_COLOR = UIColor.darkGrayColor
  NIGHT_COLOR = UIColor.colorWithRed(0.0, green:0.1, blue:0.3, alpha:1.0)

  def color
    COLORS[self.colorIndex][:value]
  end

  def cgColor
    color.CGColor
  end

end