import UIKit
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if !FkP.isInitialSetupComplete {
            initialSetup()
        }
        
        window?.tintColor = UIColor(red: 132/255.0, green: 0.0, blue: 1.0, alpha: 1.0)
        return true
    }
    
    func initialSetup() {
        try! FkP.realm.write {
            for (index, day) in Day.symbols.enumerate() {
                FkP.realm.add(Day(name: day, dayOfWeek: index))
            }
            
            FkP.realm.add(Category(value: ["name": "Home", "index": 0, "colorIndex": 0]))
            FkP.realm.add(Category(value: ["name": "Work", "index": 1, "colorIndex": 1]))
            FkP.realm.add(Category(value: ["name": "Break", "index": 2, "colorIndex": 2]))
            FkP.realm.add(Category(value: ["name": "Hobby", "index": 3, "colorIndex": 3]))
            FkP.realm.add(Category(value: ["name": "Misc", "index": 4, "colorIndex": 5]))
        }
        
        FkP.isInitialSetupComplete = true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if application.applicationState == .Active { playChime() }
    }
    
    func playChime() {
        let soundURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("chime", ofType: "caf")!)
        var notificationSoundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL, &notificationSoundID)
        AudioServicesPlaySystemSound(notificationSoundID)
        AudioServicesDisposeSystemSoundID(notificationSoundID)
    }
    
}

