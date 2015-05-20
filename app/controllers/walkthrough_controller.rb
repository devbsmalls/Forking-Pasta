class WalkthroughController < UIViewController
  extend IB

  outlet :dismissButton, UIButton

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