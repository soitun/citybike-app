//
//  RideStopwatch.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class RideStopwatch {
    typealias UpdateBlockType = (duration: NSTimeInterval) -> Void
    
//    var startTimeInterval: NSTimeInterval = 0
    private var timer: NSTimer?
    private var updateBlock: UpdateBlockType?
    private var _startDate: NSDate = NSDate()
    
    var startDate: NSDate {
        return _startDate
    }
    
    func start(startDate: NSDate, updateBlock: UpdateBlockType) {
        self.updateBlock = updateBlock
        _startDate = startDate
        self.refresh()
        
        self.timer?.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("refresh"), userInfo: nil, repeats: true)
    }
    
    @objc private func refresh() {
        self.updateBlock?(duration: self.duration())
    }
    
    func stop() -> NSTimeInterval {
        self.timer?.invalidate()
        return self.duration()
    }
    
    private func duration() -> NSTimeInterval {
        return NSDate().timeIntervalSinceDate(_startDate)
    }
}