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

  def time_remaining
    Time.at(self.endTime - Time.now.strip_seconds).utc
  end

  def time_until_start
    Time.at(self.startTime - Time.now.strip_seconds).utc
  end

  def has_overlap?
    start_during = self.schedule.periods.where(:startTime).gte(startTime).where(:startTime).lt(endTime).all.reject { |p| p == self}
    end_during = self.schedule.periods.where(:endTime).gt(startTime).where(:endTime).lte(endTime).all.reject { |p| p == self}
    before_to_after = self.schedule.periods.where(:startTime).lte(self.startTime).where(:endTime).gte(self.endTime).all.reject { |p| p == self}
    
    (start_during.count + end_during.count + before_to_after.count) > 0
  end

end