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
        NSUserDefaults.setStartRideDate(startDate)
        self.stopwatch.start(startDate, updateBlock: updateBlock)
    }
    
    func stop() {
        _isGoing = false

        let duration = self.stopwatch.stop()

        let typeComponents = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
        let components = NSCalendar.autoupdatingCurrentCalendar().components(typeComponents, fromDate: self.stopwatch.startDate)
        let startDayAtMidnight = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(components)!
        
        /// Create entry for this ride session
        let entry: CDRideHistoryEntry = CDRideHistoryEntry(context:CoreDataHelper.sharedInstance().mainContext)
        entry.date = self.stopwatch.startDate
        entry.duration = duration
        
        /// Check if there is day which can store this entry, if not crreate one
        if let day = CDRideHistoryDay.fetchWithAttribute("date", value: startDayAtMidnight, context: CoreDataHelper.sharedInstance().mainContext).first as? CDRideHistoryDay {
            day.addEntry(entry)
        } else {
            var day: CDRideHistoryDay = CDRideHistoryDay(context: CoreDataHelper.sharedInstance().mainContext)
            day.date = startDayAtMidnight
            day.addEntry(entry)
        }
        
        CoreDataHelper.sharedInstance().mainContext.save(nil)
        NSUserDefaults.removeStartRideDate()
    }
}