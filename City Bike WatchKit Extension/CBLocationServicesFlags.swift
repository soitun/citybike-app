//
//  CBLocationServicesFlags.swift
//  CityBike
//
//  Created by Tomasz Szulc on 24/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import CoreLocation

struct CBLocationServicesFlags {
    var enabled = true
    var wasEnabled = true
    var enabledChanged: Bool { return enabled != wasEnabled }
    
    var accessGranted = true
    var wasAccessGranted = true
    var accessGrantedChanged: Bool { return accessGranted != wasAccessGranted }
    
    var isWorking: Bool {
        return enabled == true && accessGranted == true
    }
    
    mutating func refreshFlags() {
        wasEnabled = enabled
        enabled = isLocationServicesEnabled()
        
        wasAccessGranted = accessGranted
        accessGranted = isLocationServicesAccessGranted()
    }
    
    private func isLocationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled() == true
    }
    
    private func isLocationServicesAccessGranted() -> Bool {
        let authStatus = CLLocationManager.authorizationStatus()
        return (authStatus == .AuthorizedAlways || authStatus == .AuthorizedWhenInUse)
    }
}