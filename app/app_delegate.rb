class AppDelegate
  include CDQ
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @storyboard = UIStoryboard.storyboardWithName("Storyboard", bundle: nil)
    @window.rootViewController = @storyboard.instantiateInitialViewController
    @window.makeKeyAndVisible

    setupDefaultCategories

    true

  end

  def setupDefaultCategories
    if Category.count < 1
      Category.new(name: "Home", index: 0, color: UIColor.colorWithRed(0.557, green:0.910, blue:1.000, alpha:1.0))
      Category.new(name: "Work", index: 1, color: UIColor.colorWithRed(0.757, green:1.000, blue:0.557, alpha:1.0))
      Category.new(name: "Misc", index: 2, color: UIColor.colorWithRed(1.000, green:0.859, blue:0.557, alpha:1.0))
      cdq.save
    end
  end

end