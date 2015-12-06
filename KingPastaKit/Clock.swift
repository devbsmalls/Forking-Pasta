import UIKit
import WatchKit
import Foundation

public class Clock {
    static let outerPadding = CGFloat(5)
    // INNER_PADDING = 10
    // LINE_WIDTH = 2
    
    static let screenScale: CGFloat = {
        #if os(watchOS)
            return WKInterfaceDevice.currentDevice().screenScale
        #else
            return UIScreen.mainScreen().scale
        #endif
    }()
    
    // TODO: Remove the tuple
    class func dimensions(rect: CGRect) -> (CGRect, CGRect, CGFloat) {
        // squareRect = compensate for rectangles
        let outerRect = CGRectInset(rect, outerPadding, (rect.size.height - rect.size.width) / 2 + outerPadding)
        let lineWidth = outerRect.size.width / 79
        
        let innerPadding = outerRect.size.width / 16
        let innerRect = CGRectInset(outerRect, innerPadding, innerPadding)
        
        return (outerRect, innerRect, lineWidth)
    }
    
    // TODO: Check day night evening blank for shareable code
    
    class func morning (rect: CGRect, periods: [Period]) -> UIImage {
        let (outerRect, innerRect, lineWidth) = dimensions(rect)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, screenScale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetGrayStrokeColor(context, 0, 1)
        CGContextSetLineWidth(context, lineWidth)
        
        // blank canvas
        CGContextSetFillColorWithColor(context, TimeZone.freeColor.CGColor)
        CGContextFillEllipseInRect(context, outerRect)
        
        // TODO: There was a check for periods != nil
        if periods.count > 0 {
            let dayStart = periods.first!.startTime
            let dayEnd = periods.last!.endTime
            let dayLength = dayEnd - dayStart
            
            // draw each period
            for period in periods {
                let startAngle = CGFloat(2 * M_PI / dayLength * (period.startTime - dayStart))
                let endAngle = CGFloat(2 * M_PI / dayLength * (period.endTime - dayStart))
                let color = period.timeZone?.cgColor ?? TimeZone.freeColor.CGColor
                drawSegment(context, rect: outerRect, startAngle: startAngle, endAngle: endAngle, color: color)
            }
        }
        
        // save state, clip to ellipse, draw texture, restore state
        if let texture = UIImage.named("morning", inBundle: NSBundle(identifier: "uk.pixlwave.KingPastaKit")) {
            CGContextSaveGState(context)
            CGContextAddEllipseInRect(context, innerRect)
            CGContextClip(context)
            texture.drawInRect(innerRect)
            CGContextRestoreGState(context)
        }
        
        // outline both circles
        CGContextStrokeEllipseInRect(context, outerRect)
        CGContextStrokeEllipseInRect(context, innerRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func day(rect: CGRect, periods: [Period], currentPeriod: Period?) -> UIImage {
        let (outerRect, innerRect, lineWidth) = dimensions(rect)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, screenScale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetGrayStrokeColor(context, 0, 1)
        CGContextSetLineWidth(context, lineWidth)
        
        // blank canvas
        CGContextSetFillColorWithColor(context, TimeZone.freeColor.CGColor)
        CGContextFillEllipseInRect(context, outerRect)
        
        // TODO: There was a check for periods != nil
        if periods.count > 0 {
            let dayStart = periods.first!.startTime
            let dayEnd = periods.last!.endTime
            let dayLength = dayEnd - dayStart
            
            // draw each period
            for period in periods {
                let startAngle = CGFloat(2 * M_PI / dayLength * (period.startTime - dayStart))
                let endAngle = CGFloat(2 * M_PI / dayLength * (period.endTime - dayStart))
                let color = period.timeZone?.cgColor ?? TimeZone.freeColor.CGColor
                drawSegment(context, rect: outerRect, startAngle: startAngle, endAngle: endAngle, color: color)
            }
            
            // shade progress through the day
            let dayTimePassed = Time.now() - dayStart
            let dayProgress = dayTimePassed / dayLength
            if dayProgress > 0 {
                if dayProgress < 1 {
                    shadeOuter(context, rect: outerRect, angle: CGFloat(2 * M_PI * dayProgress))
                } else {
                    shadeWholeOuter(context, rect: outerRect)
                }
            }
        }
        
        // draw blank if currentPeriod = nil (this will occur during free time)
        // draw current period in center
        if let currentPeriod = currentPeriod {
            CGContextSetFillColorWithColor(context, currentPeriod.timeZone?.cgColor ?? TimeZone.freeColor.CGColor)
            CGContextFillEllipseInRect(context, innerRect)
            
            // shade progress through current period
            let currentPeriodLength = currentPeriod.endTime - currentPeriod.startTime
            let currentPeriodTimePassed = Time.now() - currentPeriod.startTime
            let currentPeriodProgress = currentPeriodTimePassed / currentPeriodLength
            shadeInner(context, rect: innerRect, angle: CGFloat(2 * M_PI * currentPeriodProgress))
        } else {
            CGContextSetFillColorWithColor(context, TimeZone.freeColor.CGColor)
            CGContextFillEllipseInRect(context, innerRect)
        }
        
        // outline both circles
        CGContextStrokeEllipseInRect(context, outerRect)
        CGContextStrokeEllipseInRect(context, innerRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // TODO: Check [Period] is better than Result<Period>
    class func evening(rect: CGRect, periods: [Period]) -> UIImage {
        let (outerRect, innerRect, lineWidth) = dimensions(rect)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, screenScale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetGrayStrokeColor(context, 0, 1)
        CGContextSetLineWidth(context, lineWidth)
        
        // blank canvas
        CGContextSetFillColorWithColor(context, TimeZone.freeColor.CGColor)
        CGContextFillEllipseInRect(context, outerRect)
        
        // TODO: There was a check for periods != nil
        if periods.count > 0 {
            let dayStart = periods.first!.startTime
            let dayEnd = periods.last!.endTime
            let dayLength = dayEnd - dayStart
            
            // draw each period
            for period in periods {
                let startAngle = CGFloat(2 * M_PI / dayLength * (period.startTime - dayStart))
                let endAngle = CGFloat(2 * M_PI / dayLength * (period.endTime - dayStart))
                let color = period.timeZone?.cgColor ?? TimeZone.freeColor.CGColor
                drawSegment(context, rect: outerRect, startAngle: startAngle, endAngle: endAngle, color: color)
            }
            
            // shade all periods in the day
            shadeWholeOuter(context, rect: outerRect)
        }
        
        // save state, clip to ellipse, draw texture, restore state
        if let texture = UIImage.named("evening", inBundle: NSBundle(identifier: "uk.pixlwave.KingPastaKit")) {
            CGContextSaveGState(context)
            CGContextAddEllipseInRect(context, innerRect)
            CGContextClip(context)
            texture.drawInRect(innerRect)
            CGContextRestoreGState(context)
        }
        
        // outline both circles
        CGContextStrokeEllipseInRect(context, outerRect)
        CGContextStrokeEllipseInRect(context, innerRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    class func night(rect: CGRect) -> UIImage {
        let (outerRect, innerRect, lineWidth) = dimensions(rect)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, screenScale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetGrayStrokeColor(context, 0, 1)
        CGContextSetLineWidth(context, lineWidth)
        
        CGContextSetFillColorWithColor(context, TimeZone.nightColor.CGColor)
        CGContextFillEllipseInRect(context, outerRect)
        
        // save state, clip to ellipse, draw texture, restore state
        if let texture = UIImage.named("night", inBundle: NSBundle(identifier: "uk.pixlwave.KingPastaKit")) {
            CGContextSaveGState(context)
            CGContextAddEllipseInRect(context, innerRect)
            CGContextClip(context)
            texture.drawInRect(innerRect)
            CGContextRestoreGState(context)
        }
        
        // TODO: shade progress through night
        
        // outline both circles
        CGContextStrokeEllipseInRect(context, outerRect)
        CGContextStrokeEllipseInRect(context, innerRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    public class func blank(rect: CGRect) -> UIImage {
        let (outerRect, innerRect, lineWidth) = dimensions(rect)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, screenScale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetGrayStrokeColor(context, 0, 1)
        CGContextSetLineWidth(context, lineWidth)
        
        // blank canvas
        CGContextSetFillColorWithColor(context, TimeZone.freeColor.CGColor)
        CGContextFillEllipseInRect(context, outerRect)
        
        // outline both circles
        CGContextStrokeEllipseInRect(context, outerRect)
        CGContextStrokeEllipseInRect(context, innerRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    class func drawSegment(context: CGContextRef?, rect: CGRect, startAngle: CGFloat, endAngle: CGFloat, color: CGColorRef) {
        let path = CGPathCreateMutable()
        let arcCenterX = CGRectGetMidX(rect)
        let arcCenterY = CGRectGetMidY(rect)
        let arcRadius = rect.size.width / 2
        let startAngle = startAngle - CGFloat(M_PI_2)
        let endAngle = endAngle - CGFloat(M_PI_2)
        
        CGPathMoveToPoint(path, nil, arcCenterX, arcCenterY)
        CGPathAddArc(path, nil, arcCenterX, arcCenterY, arcRadius, startAngle, endAngle, false)
        CGPathCloseSubpath(path)
        
        CGContextSetFillColorWithColor(context, color)
        CGContextAddPath(context, path)
        CGContextFillPath(context)
        CGContextAddPath(context, path)
        CGContextStrokePath(context)
    }
    
    class func shadeOuter(context: CGContextRef?, rect: CGRect, angle: CGFloat) {
        let path = CGPathCreateMutable()
        let arcCenterX = CGRectGetMidX(rect)
        let arcCenterY = CGRectGetMidY(rect)
        let arcRadius = rect.size.width / 2
        let startAngle = CGFloat(-M_PI_2)
        let endAngle = startAngle + angle
        
        CGPathMoveToPoint(path, nil, arcCenterX, arcCenterY)
        CGPathAddArc(path, nil, arcCenterX, arcCenterY, arcRadius, startAngle, endAngle, false)
        CGPathCloseSubpath(path)
        
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.6)
        CGContextAddPath(context, path)
        CGContextFillPath(context)
    }
    
    class func shadeWholeOuter(context: CGContextRef?, rect: CGRect) {
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.6)
        CGContextFillEllipseInRect(context, rect)
    }
    
    class func shadeInner(context: CGContextRef?, rect: CGRect, angle: CGFloat) {
        let path = CGPathCreateMutable()
        let arcCenterX = CGRectGetMidX(rect)
        let arcCenterY = CGRectGetMidY(rect)
        let arcRadius = rect.size.width / 2
        let startAngle = CGFloat(-M_PI_2)
        let endAngle = startAngle + angle
        
        CGPathMoveToPoint(path, nil, arcCenterX, arcCenterY)
        CGPathAddArc(path, nil, arcCenterX, arcCenterY, arcRadius, startAngle, endAngle, false)
        CGPathCloseSubpath(path)
        
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.2)
        CGContextAddPath(context, path)
        CGContextFillPath(context)
    }
}