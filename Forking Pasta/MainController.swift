import UIKit

class MainController: UIViewController {
    
    private var tick: NSTimer?
    
    @IBOutlet weak var watchView: UIView!
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var periodNameLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watchView.layer.cornerRadius = 10
        watchView.layer.borderColor = UIColor.blackColor().CGColor
        watchView.layer.borderWidth = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if tick == nil {
            tick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "redraw", userInfo: nil, repeats: true)
        }
        // tick?.fireDate = Time.now.round + 1     // ensures the timer fires on the second     // TODO: use NSDate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        redraw()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tick = tick {
            tick.invalidate()
            self.tick = nil
        }
    }
    
    func redraw() {
        let status = FkP.status(clockImageView.bounds)
        clockImageView.image = status.clock
        periodNameLabel.text = status.periodName
        timeRemainingLabel.text = status.timeRemaining
    }
}