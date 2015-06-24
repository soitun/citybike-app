//
//  CBWormhole.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

enum CBWormholeNotification: String {
    case StopwatchStarted = "stopwatch-started"
    case StopwatchStopped = "stopwatch-stopped"
}

class CBWormhole: MMWormhole {
    
    class var sharedInstance: CBWormhole {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: CBWormhole? = nil
        }
        
        dispatch_once(&Static.onceToken, { Static.instance = CBWormhole() })
        return Static.instance!
    }
    
    init() {
        super.init(applicationGroupIdentifier: CBConstant.AppSharedGroup.rawValue, optionalDirectory: nil)
    }
}