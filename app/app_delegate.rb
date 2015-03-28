class AppDelegate
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    FkP.setup

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
      Day.create(name: day, dayOfWeek: index)
    end

    Category.create(name: "Home", index: 0, colorIndex: 0)
    Category.create(name: "Work", index: 1, colorIndex: 1)
    Category.create(name: "Break", index: 2, colorIndex: 2)
    Category.create(name: "Hobby", index: 3, colorIndex: 3)
    Category.create(name: "Misc", index: 4, colorIndex: 5)

    FkP.create(initialSetupComplete: true)

    FkP.save
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