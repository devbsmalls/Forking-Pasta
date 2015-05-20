class GettingStartedController < UIViewController
  extend IB

  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskPortrait
  end

  def dismiss
    self.presentingViewController.presentingViewController.dismissModalViewControllerAnimated(false)
  end
end