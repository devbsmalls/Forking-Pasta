class WalkthroughContentController < UIViewController
  extend IB

  attr_accessor :title, :subtitle, :text, :image, :pageIndex

  outlet :titleLabel, UILabel
  outlet :subtitleLabel, UILabel
  outlet :textLabel, UILabel
  outlet :imageView, UIImageView

  def viewDidLoad
    super

    @titleLabel.text = @title
    @titleLabel.textColor = UIColor.whiteColor
    @subtitleLabel.text = @subtitle
    @subtitleLabel.textColor = UIColor.whiteColor
    @textLabel.text = @text
    @textLabel.textColor = UIColor.whiteColor
    @imageView.image = @image
  end

  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskPortrait
  end

end