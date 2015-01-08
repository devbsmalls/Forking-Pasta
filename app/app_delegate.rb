class AppDelegate
  include CDQ
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @storyboard = UIStoryboard.storyboardWithName("Storyboard", bundle: nil)
    @window.rootViewController = @storyboard.instantiateInitialViewController
    @window.makeKeyAndVisible

    setupDays                 # only do this once
    setupDefaultCategories    # only do this once

    true

  end

  def setupDays
    if Day.count != 7
      Day.all.each do |d|
        d.destroy
      end

      NSDateFormatter.new.weekdaySymbols.each_with_index do |day, index|
        Day.new(name: day, dayOfWeek: index)
      end

      cdq.save
    end

  end

  def setupDefaultCategories
    if Category.count < 1
      Category.new(name: "Home", index: 0, color: Category::COLORS[0])
      Category.new(name: "Work", index: 1, color: Category::COLORS[1])
      Category.new(name: "Break", index: 2, color: Category::COLORS[2])
      Category.new(name: "Misc", index: 3, color: Category::COLORS[3])
      cdq.save
    end
  end

end