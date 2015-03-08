class AppDelegate
  include CDQ
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    cdq.setup

    initialSetup unless FkP.initialSetupComplete?

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @storyboard = UIStoryboard.storyboardWithName("Storyboard", bundle: nil)
    @window.rootViewController = @storyboard.instantiateInitialViewController
    @window.tintColor = UIColor.colorWithRed(132/255.0, green: 0.0, blue: 1.0, alpha: 1.0)
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

    FkP.new(initialSetupComplete: true)

    cdq.save
  end

  def application(application, didReceiveLocalNotification: notification)
    playChime if application.applicationState == UIApplicationStateActive
  end

  def playChime
    if @notification_sound_id.nil?
      soundURL = NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource("chime", ofType: "caf"))
      @notification_sound_id = Pointer.new(:uint)
      AudioServicesCreateSystemSoundID(soundURL, @notification_sound_id)
    end

    AudioServicesPlaySystemSound(@notification_sound_id[0])
  end

  def applicationWillTerminate(application)
    unless @notification_sound_id.nil?
      AudioServicesDisposeSystemSoundID(@notification_sound_id[0]);
      @notification_sound_id = nil
    end
  end

end