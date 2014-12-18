
schema "0001 initial" do

  entity "Period" do
    string :name, optional: false
    string :category, optional: false

    datetime :startTime, optional: false
    datetime :endTime, optional: false

    boolean :monday
    boolean :tuesday
    boolean :wednesday
    boolean :thursday
    boolean :friday
    boolean :saturday
    boolean :sunday
  end

end
