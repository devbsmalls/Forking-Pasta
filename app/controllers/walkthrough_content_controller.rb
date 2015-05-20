class WalkthroughContentController < UIViewController
  extend IB

  attr_accessor :title, :text, :image, :pageIndex

  outlet :titleLabel, UILabel
  outlet :textLabel, UILabel
  outlet :imageView, UIImageView

  def viewDidLoad
    super

    @titleLabel.text = @title
    @textLabel.text = @text
    @imageView.image = @image
  end

  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskPortrait
  end

end