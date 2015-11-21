import UIKit
import KingPastaKit

class WakeBedTimeController: UIViewController {
    
    var isWake = true
    
    private let lineWidth = 1.0 / UIScreen.mainScreen().scale
    private let separatorLine = UIView(frame: CGRectZero)
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var bottomView: UIVisualEffectView!
    @IBOutlet weak var embossImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ensures picker shows the time it is handed
        // timePicker.timeZone = NSTimeZone(name: "UTC")
        
        // setting in IB doesn't allow 23:00 because of timezone shit
        timePicker.maximumDate = NSDate.make(hours: 0, minutes: 0, seconds: 0)  // TODO: .utc
        timePicker.minimumDate = NSDate.make(hours: 23, minutes: 59, seconds: 59)   // TODO: .utc
        
        if isWake {
            timePicker.date = FkP.wakeTime.date()
        } else {
            navigationItem.title = "Bed Time"
            infoLabel.text = "What time do you usually go to bed?"
            timePicker.date = FkP.bedTime.date()
        }
        
        separatorLine.backgroundColor = UIColor.lightGrayColor()
        bottomView.addSubview(separatorLine)
        
        switch UIScreen.mainScreen().bounds.width {
        case 375, 667:
            embossImageView.image = UIImage(named: "icon_emboss_4.7")
        case 414, 736:
            embossImageView.image = UIImage(named: "icon_emboss_5.5")
        default:
            break
        }
        
        refreshTimeInterval()
    }
    
    override func viewWillLayoutSubviews() {
        separatorLine.frame = CGRect(x: 0, y: 0, width: bottomView.frame.width, height: lineWidth)
    }
    
    func done() {
        if isWake {
            FkP.wakeTime = timePicker.date.time()
        } else {
            FkP.bedTime = timePicker.date.time()
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func refreshTimeInterval() {
        if timePicker.date.minute % 5 != 0 || FkP.useFiveMinuteIntervals == false {
            timePicker.minuteInterval = 1
        } else {
            timePicker.minuteInterval = 5
        }
    }
    
}
