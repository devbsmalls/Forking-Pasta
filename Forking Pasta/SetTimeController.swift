import UIKit
import KingPastaKit

class SetTimeController: UIViewController {
    
    var delegate: PeriodController!
    var periodStartTime: NSTimeInterval?
    var periodEndTime: NSTimeInterval?
    var periodDay: Day!
    var isStart = false
    
    private let lineWidth = 1.0 / UIScreen.mainScreen().scale
    private let separatorLine = UIView(frame: CGRectZero)
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var jumpToTimeView: UIVisualEffectView!
    @IBOutlet weak var scheduleStartButton: UIButton!
    @IBOutlet weak var scheduleEndButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting in IB doesn't allow 23:00 because of timezone shit
        timePicker.maximumDate = NSDate.make(hours: 0, minutes: 0, seconds: 0)
        timePicker.minimumDate = NSDate.make(hours: 23, minutes: 59, seconds: 59)
        
        if isStart {
            timePicker.date = periodStartTime?.date() ?? periodDay.endTime?.date() ?? FkP.wakeTime.date()
        } else {
            navigationItem.title = "End Time"
            infoLabel.text = "Set the end time for this period"
            timePicker.date = periodEndTime?.date() ?? periodStartTime?.date() ?? FkP.bedTime.date()
        }
        
        separatorLine.backgroundColor = UIColor.lightGrayColor()
        jumpToTimeView.addSubview(separatorLine)
        
        refreshTimeInterval()
        if periodDay.startTime == nil { scheduleStartButton.enabled = false }
        if periodDay.endTime == nil { scheduleEndButton.enabled = false }
    }
    
    override func viewWillLayoutSubviews() {
        separatorLine.frame = CGRect(x: 0, y: 0, width: jumpToTimeView.frame.width, height: lineWidth)
    }
    
    func done() {
        if isStart {
            delegate.periodStartTime = timePicker.date.time()
        } else {
            delegate.periodEndTime = timePicker.date.time()
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
    
    func jumpToTime(sender: UIButton) {
        switch sender.tag {
        case 0:
            timePicker.date = FkP.wakeTime.date()
        case 1:
            if let dayStart = periodDay.startTime?.date() { timePicker.date = dayStart }
        case 2:
            timePicker.date = NSDate.make(hours: 12, minutes: 0, seconds: 0)
        case 3:
            if let dayEnd = periodDay.endTime?.date() { timePicker.date = dayEnd }
        case 4:
            timePicker.date = FkP.bedTime.date()
        default: break
        }
        
        refreshTimeInterval()
    }
    
}