class Debug
  def self.time(hours = 12, minutes = 40)
    Time.send(:define_method, :strip_date) do
      Time.at(hours*60*60 + minutes*60 + self.sec).utc
    end

    Time.send(:define_method, :strip_seconds) do
      Time.at(hours*60*60 + minutes*60).utc
    end
  end

  def self.add_work
    schedule = Schedule.create(name: "Work Debug")

    category_home = Category.all[0]
    category_work = Category.all[1]
    category_break = Category.all[2]
    category_hobby = Category.all[3]
    category_misc = Category.all[4]

    period = Period.create(name: "Walk to Work", startTime: Time.make(9, 00), endTime: Time.make(9, 30), category: category_misc, schedule: schedule)
    period = Period.create(name: "Morning", startTime: Time.make(9, 30), endTime: Time.make(10, 45), category: category_work, schedule: schedule)
    period = Period.create(name: "Break", startTime: Time.make(10, 45), endTime: Time.make(11, 00), category: category_break, schedule: schedule)
    period = Period.create(name: "Meetings", startTime: Time.make(11, 00), endTime: Time.make(12, 00), category: category_work, schedule: schedule)
    period = Period.create(name: "Lunch", startTime: Time.make(12, 00), endTime: Time.make(13, 00), category: category_home, schedule: schedule)
    period = Period.create(name: "Afternoon", startTime: Time.make(13, 00), endTime: Time.make(15, 00), category: category_work, schedule: schedule)
    period = Period.create(name: "Break", startTime: Time.make(15, 00), endTime: Time.make(15, 15), category: category_break, schedule: schedule)
    period = Period.create(name: "Research", startTime: Time.make(15, 15), endTime: Time.make(17, 00), category: category_work, schedule: schedule)
  end
end

class Time
  def self.make(hours, minutes)
    Time.at(hours*60*60 + minutes*60).utc
  end
end