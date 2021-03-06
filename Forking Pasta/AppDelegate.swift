import UIKit
import AudioToolbox
import KingPastaKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var session: WCSession?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            self.session = session
        }
        
        if !FkP.isInitialSetupComplete {
            initialSetup()
        }
        
        window?.tintColor = UIColor(red: 132/255.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        return true
    }
    
    func initialSetup() {
        let realm = FkP.realm
        try! realm.write {
            for (index, day) in Day.symbols.enumerate() {
                realm.add(Day(value: ["name": day, "dayOfWeek": index]))
            }
            
            realm.add(TimeZone(value: ["name": "Home", "index": 0, "colorIndex": 0]))
            realm.add(TimeZone(value: ["name": "Work", "index": 1, "colorIndex": 1]))
            realm.add(TimeZone(value: ["name": "Break", "index": 2, "colorIndex": 2]))
            realm.add(TimeZone(value: ["name": "Hobby", "index": 3, "colorIndex": 3]))
            realm.add(TimeZone(value: ["name": "Misc", "index": 4, "colorIndex": 5]))
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
    
    
    // MARK: Apple Watch Sync
    func syncToWatch() {
        syncDefaultsToWatch()
        syncRealmToWatch()
    }
    
    func syncDefaultsToWatch() {
        if let session = session where session.paired && session.watchAppInstalled {
            if session.outstandingUserInfoTransfers.count > 0 {
                for transfer in session.outstandingUserInfoTransfers { transfer.cancel() }
            }
            
            session.transferUserInfo(SharedDefaults.dictionaryRepresentation())
        }
    }
    
    func syncRealmToWatch() {
        if let session = session where session.paired && session.watchAppInstalled {
            if session.outstandingFileTransfers.count > 0 {
                for transfer in session.outstandingFileTransfers { transfer.cancel() }
            }
            
            if let url = FkP.realmURL {
                session.transferFile(url, metadata: ["name": "realm"])
            }
        }
    }
    
    
    // MARK: UILocalNotifications
    class func registerNotifications() {
        if !FkP.hasRegisteredNotifications {
            // TODO: Check settings conversion has worked
            let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert.union(.Sound), categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            FkP.hasRegisteredNotifications = true
        }
    }
    
    class func scheduleNotifications() {
        // TODO: Dispatch::Queue.concurrent.async do
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let today = NSDate.today()
        
        for day in FkP.realm.objects(Day) {
            if day.showsNotifications {
                let dayOffset = NSTimeInterval((7 + (day.dayOfWeek - today.dayOfWeek)) % 7)
                
                for period in day.periods {
                    let notification = UILocalNotification()
                    notification.fireDate = today.dateByAddingTimeInterval(dayOffset * 86400).dateByAddingTimeInterval(period.startTime)
                    // notification.timeZone = TODO: ensure correct
                    notification.repeatInterval = .WeekOfYear   // TODO: ensure this replaces NSWeekCalendarUnit
                    notification.alertBody = "\(period.name) has now started"
                    notification.soundName = "chime.caf"
                    
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                }
            }
        }
        // end
    }
    
    class func logNotifications() {
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for notification in notifications {
                // notification.fireDate.strftime('%e/%-m %a %k:%M')    // TODO: Convert this or remove?
                let name = notification.alertBody?.stringByReplacingOccurrencesOfString(" has now started", withString: "")
                NSLog("\(notification.fireDate)  \(name)")
            }
        }
    }
    
}


// MARK: WCSession Delegate
extension AppDelegate: WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if (message["Request Sync"] as? Bool) != nil {
            syncToWatch()
        }
    }
    
}
