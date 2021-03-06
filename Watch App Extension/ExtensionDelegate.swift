import WatchKit
import KingPastaKitWatch
import WatchConnectivity
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    var session: WCSession?

    func applicationDidFinishLaunching() {
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
        
        self.session = session
        
        // TODO: there is one more step in setting up properly on a new watch
        // ensure a realm is set up
        FkP.realm
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func requestSync() {
        session?.sendMessage(["Request Sync": true], replyHandler: nil, errorHandler: nil)
    }

}
extension ExtensionDelegate: WCSessionDelegate {
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        for key in userInfo.keys {
            SharedDefaults.setObject(userInfo[key], forKey: key)
        }
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        if file.metadata?["name"] as? String == "realm" {
            if let realmURL = FkP.realmURL {
                do {
                    if NSFileManager.defaultManager().fileExistsAtPath(FkP.realmURL!.path!) {
                        try NSFileManager.defaultManager().removeItemAtURL(realmURL)
                    }
                    try NSFileManager.defaultManager().moveItemAtURL(file.fileURL, toURL: realmURL)
                    
                    // // TODO: Only if successful
                    // let server = CLKComplicationServer.sharedInstance()
                    // for complication in server.activeComplications {
                    //     NSLog("Reloading \(complication.description)")
                    //     server.reloadTimelineForComplication(complication)
                    // }
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
}