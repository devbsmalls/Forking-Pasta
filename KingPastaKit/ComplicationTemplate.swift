import ClockKit
import RealmSwift

public class ComplicationTemplate {
    
    public static var family = CLKComplicationFamily.ModularLarge
    
    public class func placeholder() -> CLKComplicationTemplate? {
        if family == .ModularLarge {
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Current Period")
            template.body1TextProvider = CLKSimpleTextProvider(text: "Time Remaining")
            
            return template
        } else if family == .ModularSmall {
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "Cat")
            template.line2TextProvider = CLKSimpleTextProvider(text: "0:00")
            
            return template
        } else if family == .CircularSmall {
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "Cat")
            template.line2TextProvider = CLKSimpleTextProvider(text: "0:00")
            
            return template
        }
        
        return nil
    }
    
    class func with(period: Period) -> CLKComplicationTemplate {
        if family == .ModularLarge {
            let template = CLKComplicationTemplateModularLargeStandardBody()
            
            template.headerTextProvider = CLKSimpleTextProvider(text: period.name)
            template.body1TextProvider = CLKRelativeDateTextProvider(date: period.endTime.dateToday(), style: .Natural, units: NSCalendarUnit.Hour.union(.Minute))
            
            return template
        } else if family == .ModularSmall {
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: period.timeZone?.name ?? "FkP")
            template.line2TextProvider = CLKRelativeDateTextProvider(date: period.endTime.dateToday(), style: .Timer, units: NSCalendarUnit.Hour.union(.Minute))
            
            return template
        } else if family == .CircularSmall {
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: period.timeZone?.name ?? "FkP")
            template.line2TextProvider = CLKRelativeDateTextProvider(date: period.endTime.dateToday(), style: .Timer, units: NSCalendarUnit.Hour.union(.Minute))
            
            return template
        }
        
        return CLKComplicationTemplate()
    }
    
    class func free() -> CLKComplicationTemplate {
        if family == .ModularLarge {
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Free Time")
            // TODO: body
            
            return template
        } else if family == .ModularSmall {
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "Free")
            
            return template
        } else if family == .CircularSmall {
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "Free")
            
            return template
        }
        
        return CLKComplicationTemplate()
    }
}