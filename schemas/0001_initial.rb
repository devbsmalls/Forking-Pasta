
schema "0001 initial" do

  entity "Schedule" do
    string :name, optional: false

    has_many :days
    has_many :periods
  end

  entity "Day" do
    string :name, optional: false
    integer16 :dayOfWeek, optional: false
    
    belongs_to :schedule
  end

  entity "Period" do
    string :name, optional: false

    datetime :startTime, optional: false
    datetime :endTime, optional: false

    belongs_to :schedule
    belongs_to :category
  end

  entity "Category" do
    string :name, optional: false
    integer16 :index, optional: false
    transformable :color, optional: false

    has_many :periods
  end

end
