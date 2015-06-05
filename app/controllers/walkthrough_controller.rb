class WalkthroughController < UIViewController
  extend IB

  attr_accessor :backgroundImage

  outlet :backgroundImageView, UIImageView
  outlet :dismissButton, UIButton

  def viewDidLoad
    super

    @backgroundImageView.image = @backgroundImage
  end

  def preferredStatusBarStyle
    UIStatusBarStyleLightContent
  end

  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskPortrait
  end

  def skipButton
    @dismissButton.setTitle("Skip", forState: UIControlStateNormal)
  end

  def doneButton
    @dismissButton.setTitle("Done", forState: UIControlStateNormal)
  end

  def dismiss
    self.presentingViewController.dismissModalViewControllerAnimated(true)
  end
end