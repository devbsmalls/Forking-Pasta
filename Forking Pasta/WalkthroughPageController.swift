import UIKit

class WalkthroughPageController: UIPageViewController {
    
    var pages = [WalkthroughContentController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Do in storyboard
        delegate = self
        dataSource = self
        
        if let page1 = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughContentController") as? WalkthroughContentController {
            page1.heading = "Getting Started"
            page1.subtitle = ""
            page1.text = "Forking Pasta is based around Schedules. A schedule represents a plan of your time for an entire day, from start to finish."
            page1.image = UIImage(named:"getting_started_schedule")
            page1.pageIndex = 0
            
            pages.append(page1)
        }
        
        if let page2 = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughContentController") as? WalkthroughContentController {
            page2.heading = ""
            page2.subtitle = "Basic Scheduling"
            page2.text = "A simple set up could contain just one schedule called Work that occurs from Monday to Friday.\n\nThis schedule would contain time periods for all work activities throughout the day such as desk work, team meetings and breaks."
            page2.image = UIImage(named: "getting_started_work")
            page2.pageIndex = 1
            
            pages.append(page2)
        }
        
        if let page3 = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughContentController") as? WalkthroughContentController {
            page3.heading = ""
            page3.subtitle = "Advanced Scheduling"
            page3.text = "How about if you also go to the Gym on Tuesday and Thursday?\n\nAs a schedule represents an entire day plan, just create a second one called Work & Gym that details both your work activities as well as your gym session."
            page3.image = UIImage(named: "getting_started_work_gym")
            page3.pageIndex = 2
            
            pages.append(page3)
        }
        
        setViewControllers([pages[0]], direction: .Forward, animated: true, completion: nil)
    }
    
    func dismiss() {
        presentingViewController?.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
}

// MARK: UIPageViewControllerDataSource
extension WalkthroughPageController: UIPageViewControllerDataSource {
    
    func pageForIndex(index: Int) -> UIViewController {
        return pages[index]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? WalkthroughContentController)?.pageIndex else { return nil }
        
        if (1..<pages.count).contains(index) {
            return pageForIndex(index - 1)
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? WalkthroughContentController)?.pageIndex else { return nil }
        
        if (0..<pages.count - 1).contains(index) {
            return pageForIndex(index + 1)
        } else {
            return nil
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

// MARK: UIPageViewControllerDelegate
extension WalkthroughPageController: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentVC = viewControllers?.first as? WalkthroughContentController, let walkthroughVC = parentViewController as? WalkthroughController {
                contentVC.pageIndex == pages.count - 1 ? walkthroughVC.showDoneButton() : walkthroughVC.showSkipButton()
            }
        }
    }
}
