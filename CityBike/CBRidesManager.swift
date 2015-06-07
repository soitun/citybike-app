//
//  CBRidesManager.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBRidesManager {
    
    private var stopwatch = CBRideStopwatch()
    
    func startStopwatch(var ti: NSTimeInterval?, updateBlock: CBRideStopwatch.UpdateBlockType) {
        if ti == nil {
            ti = NSDate().timeIntervalSince1970
            NSUserDefaults.setStartRideTimeInterval(ti!)
        }
        
        self.stopwatch.start(ti!, updateBlock: updateBlock)
    }
}