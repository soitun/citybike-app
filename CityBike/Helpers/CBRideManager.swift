//
//  CBRideManager.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CBModel

class CBRideManager {
    
    private var stopwatch = CBRideStopwatch()
    
    private var _isGoing = false
    var isGoing: Bool {
        return _isGoing
    }
    
    func start(startDate: NSDate, updateBlock: CBRideStopwatch.UpdateBlockType) {
        _isGoing = true
        CBUserSettings.sharedInstance().setStartRideDate(startDate)
        CBWormhole.sharedInstance.passMessageObject(nil, identifier: CBWormholeNotification.StopwatchStarted.rawValue)
        self.stopwatch.start(startDate, updateBlock: updateBlock)
    }
    
    func stop() {
        _isGoing = false

        CBWormhole.sharedInstance.passMessageObject(nil, identifier: CBWormholeNotification.StopwatchStopped.rawValue)

        let duration = self.stopwatch.stop()

        let typeComponents = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
        let components = NSCalendar.autoupdatingCurrentCalendar().components(typeComponents, fromDate: self.stopwatch.startDate)
        let startDayAtMidnight = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(components)!
        
        /// Create entry for this ride session
        let entry: CDRideHistoryEntry = CDRideHistoryEntry(context:CoreDataStack.sharedInstance().mainContext)
        entry.date = self.stopwatch.startDate
        entry.duration = duration
        
        /// Check if there is day which can store this entry, if not crreate one
        if let day = CDRideHistoryDay.fetchWithAttribute("date", value: startDayAtMidnight, context: CoreDataStack.sharedInstance().mainContext).first as? CDRideHistoryDay {
            day.addEntry(entry)
        } else {
            var day: CDRideHistoryDay = CDRideHistoryDay(context: CoreDataStack.sharedInstance().mainContext)
            day.date = startDayAtMidnight
            day.addEntry(entry)
        }
        
        CoreDataStack.sharedInstance().mainContext.save(nil)
        CBUserSettings.sharedInstance().removeStartRideDate()
    }
}