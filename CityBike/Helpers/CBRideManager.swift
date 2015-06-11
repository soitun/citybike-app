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
        let dayDate = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(components)!
        
        let rideRecord = CBRideRecord(duration: duration, startTime: self.stopwatch.startTimeInterval)
        
        var ridesHistory = NSUserDefaults.getRidesHistory()
        let key = dayDate.timeIntervalSince1970
        if ridesHistory[key] != nil {
            ridesHistory[key]!.append(rideRecord)
        } else {
            ridesHistory[key] = [rideRecord]
        }
        
        NSUserDefaults.setRidesHistory(ridesHistory)
        NSUserDefaults.removeStartRideTimeInterval()
    }
}