
schema "0001 initial" do

  entity "Period" do
    string :name, optional: false

    datetime :startTime, optional: false
    datetime :endTime, optional: false

    boolean :monday
    boolean :tuesday
    boolean :wednesday
    boolean :thursday
    boolean :friday
    boolean :saturday
    boolean :sunday

    belongs_to :category
  end

  entity "Category" do
    string :name, optional: false
    integer16 :index, optional: false
    transformable :color, optional: false

    has_many :periods
  end

end
