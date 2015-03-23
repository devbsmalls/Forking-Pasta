class Period
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include MotionModel::Validatable

  columns :name => :string,
          :startTime => :date,
          :endTime => :date

  # validates :name, :presence => true
  # validates :startTime, :presence => true
  # validates :endTime, :presence => true

  belongs_to :schedule
  belongs_to :category

  def self.current
    time = Time.now.strip_date

    if periods_today = Period.all_today then periods_today.where(:startTime).lte(time).where(:endTime).gt(time).first end
  end

  def self.next
    time = Time.now.strip_date

    if periods_today = Period.all_today then periods_today.where(:startTime).gt(time).first end
  end

  def self.all_today
    if schedule_today = Schedule.today then schedule_today.all_periods end
  end

  def self.all_on_wday(wday)
    if schedule_wday = Schedule.on_wday(wday) then schedule_wday.all_periods end
  end

  def self.overlap_with_start(startTime, end: endTime, schedule: schedule, ignoring: old_period)
    start_during = schedule.periods.where(:startTime).gte(startTime).where(:startTime).lt(endTime).array.reject { |p| p == old_period }
    end_during = schedule.periods.where(:endTime).gt(startTime).where(:endTime).lte(endTime).array.reject { |p| p == old_period }
    before_to_after = schedule.periods.where(:startTime).lte(startTime).where(:endTime).gte(endTime).array.reject { |p| p == old_period }
    
    (start_during.count + end_during.count + before_to_after.count) > 0
  end

  def time_remaining
    Time.at(self.endTime - Time.now.strip_seconds).utc
  end

  def time_until_start
    Time.at(self.startTime - Time.now.strip_seconds).utc
  end

end