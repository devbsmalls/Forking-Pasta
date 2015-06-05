class WalkthroughController < UIViewController
  extend IB

  attr_accessor :backgroundImage

  outlet :backgroundImageView, UIImageView
  outlet :skipButton, UIButton
  outlet :doneButton, UIButton

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
    @doneButton.hidden = true
    @skipButton.hidden = false
  end

  def doneButton
    @skipButton.hidden = true
    @doneButton.hidden = false
  end

  def dismiss
    self.presentingViewController.dismissModalViewControllerAnimated(true)
  end
end