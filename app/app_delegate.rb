class AppDelegate
  include CDQ
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @groupDefaults = NSUserDefaults.alloc.initWithSuiteName("group.uk.pixlwave.ForkingPasta")
    initialSetup unless @groupDefaults.boolForKey("InitialSetupComplete")

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @storyboard = UIStoryboard.storyboardWithName("Storyboard", bundle: nil)
    @window.rootViewController = @storyboard.instantiateInitialViewController
    @window.makeKeyAndVisible

    true

  end

  def initialSetup
    Day.symbols.each_with_index do |day, index|
      Day.new(name: day, dayOfWeek: index)
    end

    Category.new(name: "Home", index: 0, color: Category::COLORS[0][:value])
    Category.new(name: "Work", index: 1, color: Category::COLORS[1][:value])
    Category.new(name: "Break", index: 2, color: Category::COLORS[2][:value])
    Category.new(name: "Hobby", index: 3, color: Category::COLORS[3][:value])
    Category.new(name: "Misc", index: 4, color: Category::COLORS[4][:value])

    cdq.save

    @groupDefaults.setBool(true, forKey: "InitialSetupComplete")
  end

end