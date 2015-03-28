class Clock

  OUTER_PADDING = 5
  # INNER_PADDING = 10
  # LINE_WIDTH = 2

  if NSBundle.mainBundle.bundleIdentifier.end_with?("watchkitextension")
    SCREEN_SCALE = WKInterfaceDevice.currentDevice.screenScale
  else
    SCREEN_SCALE = UIScreen.mainScreen.scale
  end

  def self.dimensions(rect)
    # squareRect = compensate for rectangles
    outerRect = CGRectInset(rect, OUTER_PADDING, (rect.size.height - rect.size.width) / 2 + OUTER_PADDING)
    lineWidth = outerRect.size.width / 79
    
    innerPadding = outerRect.size.width / 16
    innerRect = CGRectInset(outerRect, innerPadding, innerPadding)
    
    return outerRect, innerRect, lineWidth
  end

  def self.morning (rect, periods)
    outerRect, innerRect, lineWidth = dimensions(rect)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, SCREEN_SCALE)
    context = UIGraphicsGetCurrentContext()

    CGContextSetGrayStrokeColor(context, 0, 1)
    CGContextSetLineWidth(context, lineWidth)

    # blank canvas
    CGContextSetFillColorWithColor(context, Category::FREE_COLOR.CGColor)
    CGContextFillEllipseInRect(context, outerRect)

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
    end

    # save state, clip to ellipse, draw texture, restore state
    CGContextSaveGState(context)
    CGContextAddEllipseInRect(context, innerRect)
    CGContextClip(context)
    UIImage.imageNamed("morning", inBundle: NSBundle.bundleWithIdentifier('uk.pixlwave.KingPastaKit'), compatibleWithTraitCollection: nil).drawInRect(innerRect)
    CGContextRestoreGState(context)

    # outline both circles
    CGContextStrokeEllipseInRect(context, outerRect)
    CGContextStrokeEllipseInRect(context, innerRect)

    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    image
  end

  def self.day(rect, periods, currentPeriod)
    outerRect, innerRect, lineWidth = dimensions(rect)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, SCREEN_SCALE)
    context = UIGraphicsGetCurrentContext()

    CGContextSetGrayStrokeColor(context, 0, 1)
    CGContextSetLineWidth(context, lineWidth)

    # blank canvas
    CGContextSetFillColorWithColor(context, Category::FREE_COLOR.CGColor)
    CGContextFillEllipseInRect(context, outerRect)

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

    # draw blank if currentPeriod = nil (this will occur during free time)
    # draw current period in center
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

  def self.evening(rect, periods)
    outerRect, innerRect, lineWidth = dimensions(rect)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, SCREEN_SCALE)
    context = UIGraphicsGetCurrentContext()

    CGContextSetGrayStrokeColor(context, 0, 1)
    CGContextSetLineWidth(context, lineWidth)

    # blank canvas
    CGContextSetFillColorWithColor(context, Category::FREE_COLOR.CGColor)
    CGContextFillEllipseInRect(context, outerRect)

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

      # shade all periods in the day
      shadeWholeOuter(context, outerRect)

    end

    # save state, clip to ellipse, draw texture, restore state
    CGContextSaveGState(context)
    CGContextAddEllipseInRect(context, innerRect)
    CGContextClip(context)
    UIImage.imageNamed("evening", inBundle: NSBundle.bundleWithIdentifier('uk.pixlwave.KingPastaKit'), compatibleWithTraitCollection: nil).drawInRect(innerRect)
    CGContextRestoreGState(context)

    # outline both circles
    CGContextStrokeEllipseInRect(context, outerRect)
    CGContextStrokeEllipseInRect(context, innerRect)

    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    image
  end

  def self.night(rect)
    outerRect, innerRect, lineWidth = dimensions(rect)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, SCREEN_SCALE)
    context = UIGraphicsGetCurrentContext()

    CGContextSetGrayStrokeColor(context, 0, 1)
    CGContextSetLineWidth(context, lineWidth)

    CGContextSetFillColorWithColor(context, Category::NIGHT_COLOR.CGColor)
    CGContextFillEllipseInRect(context, outerRect)

    # save state, clip to ellipse, draw texture, restore state
    CGContextSaveGState(context)
    CGContextAddEllipseInRect(context, innerRect)
    CGContextClip(context)
    UIImage.imageNamed("night", inBundle: NSBundle.bundleWithIdentifier('uk.pixlwave.KingPastaKit'), compatibleWithTraitCollection: nil).drawInRect(innerRect)
    CGContextRestoreGState(context)
    
    # TODO: shade progress through night

    # outline both circles
    CGContextStrokeEllipseInRect(context, outerRect)
    CGContextStrokeEllipseInRect(context, innerRect)

    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    image
  end

  def self.blank(rect)
    outerRect, innerRect, lineWidth = dimensions(rect)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, SCREEN_SCALE)
    context = UIGraphicsGetCurrentContext()

    CGContextSetGrayStrokeColor(context, 0, 1)
    CGContextSetLineWidth(context, lineWidth)

    # blank canvas
    CGContextSetFillColorWithColor(context, Category::FREE_COLOR.CGColor)
    CGContextFillEllipseInRect(context, outerRect)

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

    CGContextSetRGBFillColor(context, 0, 0, 0, 0.2)
    CGContextAddPath(context, path)
    CGContextFillPath(context)
  end

end