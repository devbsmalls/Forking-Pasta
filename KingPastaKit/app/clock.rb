class Clock

  OUTER_PADDING = 5
  INNER_PADDING = 10
  LINE_WIDTH = 2

  if NSBundle.mainBundle.bundleIdentifier.end_with?("watchkitextension")
    SCREEN_SCALE = WKInterfaceDevice.currentDevice.screenScale
  else
    SCREEN_SCALE = UIScreen.mainScreen.scale
  end

  def self.day(rect)
    # squareRect = compensate for rectangles
    outerRect = CGRectInset(rect, OUTER_PADDING, (rect.size.height - rect.size.width) / 2 + OUTER_PADDING)
    innerRect = CGRectInset(outerRect, INNER_PADDING, INNER_PADDING)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, SCREEN_SCALE)
    context = UIGraphicsGetCurrentContext()

    CGContextSetGrayStrokeColor(context, 0, 1)
    CGContextSetLineWidth(context, LINE_WIDTH)

    # this needs a 'free time' category colour that the user can't use
    # blank canvas
    CGContextSetFillColorWithColor(context, Category::FREE_COLOR.CGColor)
    CGContextFillEllipseInRect(context, outerRect)
    
    periods = Period.all_today

    if periods && periods.count > 0
      dayStart = periods.first.startTime
      dayEnd = periods[periods.count - 1].endTime     # why can't I use .last?!?!
      dayLength = dayEnd - dayStart

      # draw each period
      periods.each do |period|
        startAngle = 2 * Math::PI / dayLength * (period.startTime - dayStart)
        endAngle = 2 * Math::PI / dayLength * (period.endTime - dayStart)
        color = period.category.cgColor
        drawSegment(context, outerRect, startAngle, endAngle, color)
      end

      # shade progress through the day
      dayTimePassed = Time.now.strip_date.utc - dayStart
      dayProgress = dayTimePassed / dayLength
      if dayProgress > 0
        if dayProgress < 1
          shadeOuter(context, outerRect, 2 * Math::PI * dayProgress)
        else
          shadeWholeOuter(context, outerRect)
        end
      end

    end

    # draw blank if currentPeriod = nil
    # draw current period in center
    currentPeriod = Period.current

    if ! currentPeriod.nil?
      CGContextSetFillColorWithColor(context, currentPeriod.category.cgColor)
      CGContextFillEllipseInRect(context, innerRect)

      # shade progress through current period
      currentPeriodLength = currentPeriod.endTime - currentPeriod.startTime
      currentPeriodTimePassed = Time.now.strip_date.utc - currentPeriod.startTime
      currentPeriodProgress = currentPeriodTimePassed / currentPeriodLength
      shadeInner(context, innerRect, 2 * Math::PI * currentPeriodProgress)
    else
      CGContextSetFillColorWithColor(context, Category::FREE_COLOR.CGColor)
      CGContextFillEllipseInRect(context, innerRect)
    end

    # outline both circles
    CGContextStrokeEllipseInRect(context, outerRect)
    CGContextStrokeEllipseInRect(context, innerRect)

    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    image
  end

  def self.night(rect)
    # squareRect = compensate for rectangles
    outerRect = CGRectInset(rect, OUTER_PADDING, (rect.size.height - rect.size.width) / 2 + OUTER_PADDING)
    innerRect = CGRectInset(outerRect, INNER_PADDING, INNER_PADDING)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen.scale)
    context = UIGraphicsGetCurrentContext()

    CGContextSetGrayStrokeColor(context, 0, 1)
    CGContextSetLineWidth(context, LINE_WIDTH)

    CGContextSetFillColorWithColor(context, Category::NIGHT_COLOR.CGColor)
    CGContextFillEllipseInRect(context, outerRect)
    
    CGContextSetFillColorWithColor(context, Category::NIGHT_COLOR.CGColor)
    CGContextFillEllipseInRect(context, innerRect)
    
    currentPeriod = Period.current

    if ! currentPeriod.nil?
      # TODO: shade progress through night
      currentPeriodLength = currentPeriod.endTime - currentPeriod.startTime
      currentPeriodTimePassed = Time.now.strip_date.utc - currentPeriod.startTime
      currentPeriodProgress = currentPeriodTimePassed / currentPeriodLength
      shadeInner(context, innerRect, 2 * Math::PI * currentPeriodProgress)
    end

    # outline both circles
    CGContextStrokeEllipseInRect(context, outerRect)
    CGContextStrokeEllipseInRect(context, innerRect)

    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    image
  end

  def self.drawSegment(context, rect, startAngle, endAngle, color)
    path = CGPathCreateMutable()
    arcCenterX = CGRectGetMidX(rect)
    arcCenterY = CGRectGetMidY(rect)
    arcRadius = rect.size.width / 2
    startAngle = startAngle - (Math::PI / 2)
    endAngle = endAngle - (Math::PI / 2)

    CGPathMoveToPoint(path, nil, arcCenterX, arcCenterY)
    CGPathAddArc(path, nil, arcCenterX, arcCenterY, arcRadius, startAngle, endAngle, false)
    CGPathCloseSubpath(path)

    CGContextSetFillColorWithColor(context, color)
    CGContextAddPath(context, path)
    CGContextFillPath(context)
    CGContextAddPath(context, path)
    CGContextStrokePath(context)
  end

  def self.shadeOuter(context, rect, angle)
    path = CGPathCreateMutable()
    arcCenterX = CGRectGetMidX(rect)
    arcCenterY = CGRectGetMidY(rect)
    arcRadius = rect.size.width / 2
    startAngle = -Math::PI / 2
    endAngle = startAngle + angle

    CGPathMoveToPoint(path, nil, arcCenterX, arcCenterY)
    CGPathAddArc(path, nil, arcCenterX, arcCenterY, arcRadius, startAngle, endAngle, false)
    CGPathCloseSubpath(path)

    CGContextSetRGBFillColor(context, 0, 0, 0, 0.6)
    CGContextAddPath(context, path)
    CGContextFillPath(context)
  end

  def self.shadeWholeOuter(context, rect)
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.6)
    CGContextFillEllipseInRect(context, rect)
  end

  def self.shadeInner(context, rect, angle)
    path = CGPathCreateMutable()
    arcCenterX = CGRectGetMidX(rect)
    arcCenterY = CGRectGetMidY(rect)
    arcRadius = rect.size.width / 2
    startAngle = -Math::PI / 2
    endAngle = startAngle + angle

    CGPathMoveToPoint(path, nil, arcCenterX, arcCenterY)
    CGPathAddArc(path, nil, arcCenterX, arcCenterY, arcRadius, startAngle, endAngle, false)
    CGPathCloseSubpath(path)

    CGContextSetRGBFillColor(context, 0, 0, 0, 0.3)
    CGContextAddPath(context, path)
    CGContextFillPath(context)
  end

end