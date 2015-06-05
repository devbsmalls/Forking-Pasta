class WalkthroughPageController < UIPageViewController
  extend IB

  def viewDidLoad

    self.delegate = self
    self.dataSource = self

    # UIPageControl.appearance.pageIndicatorTintColor = UIColor.lightGrayColor
    # UIPageControl.appearance.currentPageIndicatorTintColor = UIColor.blackColor

    page1 = storyboard.instantiateViewControllerWithIdentifier("WalkthroughContentController")
    page1.title = "Getting Started"
    page1.subtitle = ""
    page1.text = "Forking Pasta is based around Schedules. A schedule represents a plan of your time for an entire day, from start to finish."
    page1.image = UIImage.imageNamed("getting_started_schedule")
    page1.pageIndex = 0

    page2 = storyboard.instantiateViewControllerWithIdentifier("WalkthroughContentController")
    page2.title = ""
    page2.subtitle = "Basic Scheduling"
    page2.text = "A simple set up could contain just one schedule called Work that occurs from Monday to Friday.\n\nThis schedule would contain time periods for all work activies throughout the day such as solo desk work, team meetings and breaks."
    page2.image = UIImage.imageNamed("getting_started_work")
    page2.pageIndex = 1

    page3 = storyboard.instantiateViewControllerWithIdentifier("WalkthroughContentController")
    page3.title = ""
    page3.subtitle = "Advanced Scheduling"
    page3.text = "A more complex set up may involve 3 schedules such as Work & Gym on Monday, Wednesday and Friday, Work on Tuesday and Thursday and Sports Clubs on Saturday."
    page3.image = UIImage.imageNamed("getting_started_work_gym")
    page3.pageIndex = 2

    @pages = [page1, page2, page3]

    self.setViewControllers([page1], direction: UIPageViewControllerNavigationDirectionForward, animated: true, completion: nil)
  end

  def dismiss
    self.presentingViewController.presentingViewController.dismissModalViewControllerAnimated(false)
  end


  #### page view delegate methods ####
  def pageForIndex(index)
    @pages[index]
  end

  def pageViewController(pageViewController, viewControllerBeforeViewController: viewController)
    index = viewController.pageIndex

    if (1..(@pages.count - 1)).include? index
      index -= 1
      pageForIndex(index)
    else
      nil
    end
  end

  def pageViewController(pageViewController, viewControllerAfterViewController: viewController)
    index = viewController.pageIndex

    if (0..(@pages.count - 2)).include? index
      index += 1
      pageForIndex(index)
    else
      nil
    end
  end

  def pageViewController(pageViewController, didFinishAnimating: finished, previousViewControllers: previousViewControllers, transitionCompleted: completed)
    if completed
      self.viewControllers.first.pageIndex == @pages.count - 1 ? self.parentViewController.doneButton : self.parentViewController.skipButton
    end
  end

  def presentationCountForPageViewController(pageViewController)
    @pages.count
  end

  def presentationIndexForPageViewController(pageViewController)
    0
  end

end