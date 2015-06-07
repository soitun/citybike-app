//
//  CBRideRecord.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

typealias RideDay = NSTimeInterval /// since 1970 at 00:00 of the day
typealias RidesHistory = [RideDay: [CBRideRecord]]
typealias RidesHistoryArchived = [RideDay: [NSData]] /// Used for NSKeyedArchiver

class CBRideRecord: NSObject, NSCoding {
    var duration: NSTimeInterval = 0
    var startTime: NSTimeInterval = 0
    
    init(duration: NSTimeInterval, startTime: NSTimeInterval) {
        self.duration = duration
        self.startTime = startTime
    }
    
    required init(coder aDecoder: NSCoder) {
        self.duration = aDecoder.decodeDoubleForKey("duration")
        self.startTime = aDecoder.decodeDoubleForKey("startTime")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(self.duration, forKey: "duration")
        aCoder.encodeDouble(self.startTime, forKey: "startTime")
    }
}