
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

  entity "FkP" do
    boolean :initialSetupComplete, default: false, optional: false

    datetime :wakeTime, default: Time.at(8*60*60 + 0*60 + 0).utc, optional: false
    datetime :bedTime, default: Time.at(22*60*60 + 30*60 + 0).utc, optional: false
  end

end
