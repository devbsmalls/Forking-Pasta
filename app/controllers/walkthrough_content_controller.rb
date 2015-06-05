class WalkthroughContentController < UIViewController
  extend IB

  attr_accessor :title, :text, :image, :pageIndex

  outlet :titleLabel, UILabel
  outlet :textLabel, UILabel
  outlet :imageView, UIImageView

  def viewDidLoad
    super

    @titleLabel.text = @title
    @titleLabel.textColor = UIColor.whiteColor
    @textLabel.text = @text
    @textLabel.textColor = UIColor.whiteColor
    @imageView.image = @image
  end

  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskPortrait
  end

end