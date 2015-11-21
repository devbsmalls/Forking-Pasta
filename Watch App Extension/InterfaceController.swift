import WatchKit
import Foundation
import KingPastaKit

class InterfaceController: WKInterfaceController {
    
    var clockRect = WKInterfaceDevice.currentDevice().screenBounds.width < 156 ? CGRect(x: 0, y: 0, width: 100, height: 100) : CGRect(x: 0, y: 0, width: 120, height: 120)
    
    private var tick: NSTimer?
    
    @IBOutlet weak var periodNameLabel: WKInterfaceLabel!
    @IBOutlet weak var clockImage: WKInterfaceImage!
    @IBOutlet weak var timeRemainingLabel: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        //
    }

    override func willActivate() {
        super.willActivate()
        
        if FkP.isInitialSetupComplete {
            if tick == nil {
                tick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "refresh", userInfo: nil, repeats: true)
                refresh()
            }
        } else {
            clockImage.image = Clock.blank(clockRect)
            periodNameLabel.text = "Free time"
            timeRemainingLabel.text = "Nothing scheduled"
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
