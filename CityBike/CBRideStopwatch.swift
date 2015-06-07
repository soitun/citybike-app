//
//  CBRideStopwatch.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBRideStopwatch {
    typealias UpdateBlockType = (duration: NSTimeInterval) -> Void
    
    var startTimeInterval: NSTimeInterval = 0
    private var timer: NSTimer?
    private var updateBlock: UpdateBlockType?
    
    var isMeasuring: Bool = false
    
    func start(timeInterval: NSTimeInterval, updateBlock: UpdateBlockType) {
        self.isMeasuring = true
        
        self.updateBlock = updateBlock
        
        self.startTimeInterval = timeInterval
        self.refresh()
        
        self.timer?.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("refresh"), userInfo: nil, repeats: true)
    }
    
    @objc private func refresh() {
        self.updateBlock?(duration: self.duration())
    }
    
    func stop() -> NSTimeInterval {
        self.isMeasuring = false
        
        self.timer?.invalidate()
        return self.duration()
    }
    
    private func duration() -> NSTimeInterval {
        return NSDate().timeIntervalSince1970 - self.startTimeInterval
    }
}