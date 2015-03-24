class Schedule
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include MotionModel::Validatable

  columns :name => { :type => :string, :default => "" },
          :showsNotifications => { :type => :boolean, :default => false }

  # validates :name, :presence => true
  # validates :showsNotifications, :presence => true

  has_many :days
  has_many :periods

  def ordered_periods
    self.periods.order(:startTime)
  end

  def days_string
    case days.count
    when 0
      " "       # space stops detailTextLabel collapsing to a size of 0 in the ScheduleController
    when 1
      days.first.name
    when 2
      days_array = days.order(:dayOfWeek).array
      days_array = days_array.reverse if days_array[0].dayOfWeek == 0 && days_array[1].dayOfWeek == 6   # puts days 0 & 6 in running order
      days_array.map { |day| day.name }.join(" & ")
    else
      days_array = days.order(:dayOfWeek).array
      days_array.take(days_array.count - 1).map { |day| Day.shortSymbols[day.dayOfWeek] }.join(", ") + " & #{Day.shortSymbols[days_array.last.dayOfWeek]}"
    end
  end

  def started?
    return false if ordered_periods.count < 1
    Time.now.strip_date > ordered_periods.array.first.startTime
  end

  def start_time
    case self.periods.count
    when 0
      nil
    when 1
      self.periods.first.startTime
    else
      self.ordered_periods.array.reject { |p| p.startTime == nil }.first.startTime  # rejects unsaved objects which don't have a start time
    end
  end

  def end_time
    case self.periods.count
    when 0
      nil
    when 1
      self.periods.first.endTime
    else
      self.ordered_periods.array.reject { |p| p.startTime == nil }.last.endTime  # array helps reliable objects while editing and allows for .last
    end
  end

  def length
    end_time - start_time
  end

  def shows_notifications?
    self.showsNotifications unless self.showsNotifications.nil?
  end

  def shows_notifications=(bool)
    self.showsNotifications = bool
  end

  def self.today
    if day_today = Day.today then day_today.schedule end
  end

  def self.tomorrow
    if day_tomorrow = Day.tomorrow then day_tomorrow.schedule end
  end

  def self.on_wday(wday)
    if day_wday = Day.wday(wday) then day_wday.schedule end
  end

end