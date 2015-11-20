import UIKit

class WalkthroughController: UIViewController {
    
    var backgroundImage: UIImage?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = backgroundImage
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    func showSkipButton() {
        doneButton.hidden = true
        skipButton.hidden = false
    }
    
    func showDoneButton() {
        skipButton.hidden = true
        doneButton.hidden = false
    }
    
    func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}