import UIKit

class WalkthroughContentController: UIViewController {
    var heading: String?
    var subtitle: String?
    var text: String?
    var image: UIImage?
    var pageIndex: Int = 0
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headingLabel.text = heading
        headingLabel.textColor = UIColor.whiteColor()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = UIColor.whiteColor()
        textLabel.text = text
        textLabel.textColor = UIColor.whiteColor()
        imageView.image = image
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}