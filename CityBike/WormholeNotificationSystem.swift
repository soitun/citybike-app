//
//  WormholeNotificationSystem.swift
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

class WormholeNotificationSystem: MMWormhole {
    
    class var sharedInstance: WormholeNotificationSystem {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: WormholeNotificationSystem? = nil
        }
        
        dispatch_once(&Static.onceToken, { Static.instance = WormholeNotificationSystem() })
        return Static.instance!
    }
    
    init() {
        super.init(applicationGroupIdentifier: Constant.AppSharedGroup.rawValue, optionalDirectory: nil)
    }
}