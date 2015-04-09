class Debug
  def self.time(hours = 11, minutes = 20)
    Time.send(:define_method, :strip_date) do
      Time.at(hours*60*60 + minutes*60 + self.sec).utc
    end

    Time.send(:define_method, :strip_seconds) do
      Time.at(hours*60*60 + minutes*60).utc
    end
  end

  def self.add_work
    schedule_work = Schedule.create(name: "Work")
    schedule_offsite = Schedule.create(name: "Work Offsite")
    Schedule.create(name: "Weekend")
    Schedule.create(name: "Bank Holiday")

    category_home = Category.all[0]
    category_work = Category.all[1]
    category_break = Category.all[2]
    category_hobby = Category.all[3]
    category_misc = Category.all[4]

    Period.create(name: "Walk to Work", startTime: Time.make(8, 30), endTime: Time.make(8, 50), category: category_misc, schedule: schedule_work)
    Period.create(name: "Toast Time", startTime: Time.make(8, 50), endTime: Time.make(9, 00), category: category_break, schedule: schedule_work)
    Period.create(name: "Project Meeting", startTime: Time.make(9, 00), endTime: Time.make(10, 00), category: category_work, schedule: schedule_work)
    Period.create(name: "Email", startTime: Time.make(10, 00), endTime: Time.make(10, 30), category: category_work, schedule: schedule_work)
    Period.create(name: "Coffee", startTime: Time.make(10, 30), endTime: Time.make(10, 45), category: category_break, schedule: schedule_work)
    Period.create(name: "Maintenance", startTime: Time.make(10, 45), endTime: Time.make(12, 00), category: category_work, schedule: schedule_work)
    Period.create(name: "Lunch", startTime: Time.make(12, 00), endTime: Time.make(13, 00), category: category_home, schedule: schedule_work)
    Period.create(name: "Afternoon", startTime: Time.make(13, 00), endTime: Time.make(15, 00), category: category_work, schedule: schedule_work)
    Period.create(name: "Tea Break", startTime: Time.make(15, 00), endTime: Time.make(15, 15), category: category_break, schedule: schedule_work)
    Period.create(name: "Research", startTime: Time.make(15, 15), endTime: Time.make(17, 00), category: category_work, schedule: schedule_work)

    # screenshots made with Debug.time(11, 20)
    Period.create(name: "Walk to Work", startTime: Time.make(9, 00), endTime: Time.make(9, 30), category: category_misc, schedule: schedule_offsite)
    Period.create(name: "Period 1", startTime: Time.make(9, 30), endTime: Time.make(10, 45), category: category_work, schedule: schedule_offsite)
    Period.create(name: "Break", startTime: Time.make(10, 45), endTime: Time.make(11, 00), category: category_break, schedule: schedule_offsite)
    Period.create(name: "Research", startTime: Time.make(11, 00), endTime: Time.make(12, 00), category: category_work, schedule: schedule_offsite)
    Period.create(name: "Lunch", startTime: Time.make(12, 00), endTime: Time.make(13, 00), category: category_home, schedule: schedule_offsite)
    Period.create(name: "Period 2", startTime: Time.make(13, 00), endTime: Time.make(14, 00), category: category_work, schedule: schedule_offsite)
    Period.create(name: "Break", startTime: Time.make(14, 00), endTime: Time.make(14, 15), category: category_break, schedule: schedule_offsite)
    Period.create(name: "Walk Home", startTime: Time.make(14, 15), endTime: Time.make(14, 45), category: category_misc, schedule: schedule_offsite)
    Period.create(name: "Gym", startTime: Time.make(14, 45), endTime: Time.make(15, 30), category: category_hobby, schedule: schedule_offsite)
    Period.create(name: "Period 3", startTime: Time.make(15, 30), endTime: Time.make(17, 00), category: category_work, schedule: schedule_offsite)
    Period.create(name: "Evening", startTime: Time.make(17, 00), endTime: Time.make(19, 00), category: category_work, schedule: schedule_offsite)
  end
end

class Time
  def self.make(hours, minutes)
    Time.at(hours*60*60 + minutes*60).utc
  end
end