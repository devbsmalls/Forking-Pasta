import UIKit
import NotificationCenter
import KingPastaKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var periodNameLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    private var tick: NSTimer?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        periodNameLabel.text = " "
        timeRemainingLabel.text = " "
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // FIXME: Called on disapper?
        print("did appear")
        if FkP.isInitialSetupComplete {
            if tick == nil {
                tick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "refresh", userInfo: nil, repeats: true)
            }
        } else {
            nothingScheduled()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tick = tick {
            tick.invalidate()
            self.tick = nil
        }
    }
    
    func refresh() {
        print("tick!")
        let status = FkP.status(clockImageView.bounds)
        clockImageView.image = status.clock
        periodNameLabel.text = status.periodName
        timeRemainingLabel.text = status.timeRemaining
    }
    
    func nothingScheduled() {
        clockImageView.image = Clock.blank(clockImageView.bounds)
        periodNameLabel.text = "Free time"
        timeRemainingLabel.text = "Nothing scheduled"
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        if FkP.isInitialSetupComplete {
            refresh()
        } else {
         nothingScheduled()
        }

        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        // defaults: top: 0, left: 47, bottom: 39, right: 0)
        return UIEdgeInsets(top: 10, left: defaultMarginInsets.left, bottom: 10, right: 0)
    }
    
}
