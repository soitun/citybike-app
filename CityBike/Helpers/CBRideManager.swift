//
//  CBRideManager.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBRideManager {
    
    private var stopwatch = CBRideStopwatch()
    
    private var _isGoing = false
    var isGoing: Bool {
        return _isGoing
    }
    
    func start(var ti: NSTimeInterval?, updateBlock: CBRideStopwatch.UpdateBlockType) {
        _isGoing = true
        if ti == nil {
            ti = NSDate().timeIntervalSince1970
            NSUserDefaults.setStartRideTimeInterval(ti!)
        }
        
        self.stopwatch.start(ti!, updateBlock: updateBlock)
    }
    
    func stop() {
        _isGoing = false
        let duration = self.stopwatch.stop()
        let startDate = NSDate(timeIntervalSince1970: self.stopwatch.startTimeInterval)
        let typeComponents = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit
        let components = NSCalendar.autoupdatingCurrentCalendar().components(typeComponents, fromDate: startDate)
        let dateOfTheStartDay = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(components)!
        
        let timeIntervalOfStartDay = dateOfTheStartDay.timeIntervalSince1970

        
        let entry: CBRideHistoryEntry = CBRideHistoryEntry.create(CoreDataHelper.mainContext)
        entry.startTimeInterval = self.stopwatch.startTimeInterval
        entry.duration = duration
        
        if let day = CBRideHistoryDay.findDayForStartTimeInterval(timeIntervalOfStartDay) {
            day.addEntry(entry)
        } else {
            var day: CBRideHistoryDay = CBRideHistoryDay.create(CoreDataHelper.mainContext)
            day.startTimeInterval = timeIntervalOfStartDay
            day.addEntry(entry)
        }
        
        CoreDataHelper.mainContext.save(nil)
        NSUserDefaults.removeStartRideTimeInterval()
    }
}