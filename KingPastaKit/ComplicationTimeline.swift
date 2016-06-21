import ClockKit
import RealmSwift

public class ComplicationTimeline {
    
    public class func current() -> CLKComplicationTimelineEntry {
        if let period = Period.current() {
            return CLKComplicationTimelineEntry(date: period.startTime.dateToday(), complicationTemplate: ComplicationTemplate.with(period))
        }
        
        return CLKComplicationTimelineEntry(date: FkP.bedTime.dateToday(), complicationTemplate: ComplicationTemplate.free())
    }
    
    public class func beforeDate(date: NSDate, limit: Int) -> [CLKComplicationTimelineEntry]? {
        if let periods = Period.allToday() {
            let selection = periods.filter { $0.startTime < date.time() }.suffix(limit)
            let timelines = selection.map { CLKComplicationTimelineEntry(date: $0.startTime.dateToday(), complicationTemplate: ComplicationTemplate.with($0)) }
            return timelines
        }
        
        return nil
    }
    
    public class func afterDate(date: NSDate, limit: Int) -> [CLKComplicationTimelineEntry]? {
        if let periods = Period.allToday() {
            let selection = periods.filter { $0.startTime > date.time() }.prefix(limit)
            let timelines = selection.map { CLKComplicationTimelineEntry(date: $0.startTime.dateToday(), complicationTemplate: ComplicationTemplate.with($0)) }
            return timelines
        }
        
        return nil
    }
    
}