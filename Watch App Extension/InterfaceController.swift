import WatchKit
import Foundation
import KingPastaKitWatch

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
            clockImage.setImage(Clock.blank(clockRect))
            periodNameLabel.setText("Free time")
            timeRemainingLabel.setText("Nothing scheduled")
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
        
        if let tick = tick {
            tick.invalidate()
            self.tick = nil
        }
    }
    
    func refresh() {
        let status = FkP.status(clockRect)
        clockImage.setImage(status.clock)
        periodNameLabel.setText(status.periodName)
        timeRemainingLabel.setText(status.timeRemaining)
    }

}
