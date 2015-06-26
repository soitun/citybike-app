//
//  RideManager.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import Model

class RideManager {
    
    private var stopwatch = RideStopwatch()
    
    private var _isGoing = false
    var isGoing: Bool {
        return _isGoing
    }
    
    func start(startDate: NSDate, updateBlock: RideStopwatch.UpdateBlockType) {
        _isGoing = true
        UserSettings.sharedInstance().setStartRideDate(startDate)
        WormholeNotificationSystem.sharedInstance.passMessageObject(nil, identifier: CBWormholeNotification.StopwatchStarted.rawValue)
        self.stopwatch.start(startDate, updateBlock: updateBlock)
    }
    
    func stop() {
        _isGoing = false

        WormholeNotificationSystem.sharedInstance.passMessageObject(nil, identifier: CBWormholeNotification.StopwatchStopped.rawValue)

        let duration = self.stopwatch.stop()

        let typeComponents = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
        let components = NSCalendar.autoupdatingCurrentCalendar().components(typeComponents, fromDate: self.stopwatch.startDate)
        let startDayAtMidnight = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(components)!
        
        /// Create entry for this ride session
        let entry: RideHistoryEntry = RideHistoryEntry(context:CoreDataStack.sharedInstance().mainContext)
        entry.date = self.stopwatch.startDate
        entry.duration = duration
        
        /// Check if there is day which can store this entry, if not crreate one
        if let day = RideHistoryDay.fetchWithAttribute("date", value: startDayAtMidnight, context: CoreDataStack.sharedInstance().mainContext).first as? RideHistoryDay {
            day.addEntry(entry)
        } else {
            var day: RideHistoryDay = RideHistoryDay(context: CoreDataStack.sharedInstance().mainContext)
            day.date = startDayAtMidnight
            day.addEntry(entry)
        }
        
        CoreDataStack.sharedInstance().mainContext.save(nil)
        UserSettings.sharedInstance().removeStartRideDate()
    }
}