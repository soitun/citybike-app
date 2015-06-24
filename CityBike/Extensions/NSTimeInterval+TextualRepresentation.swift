//
//  CBNSTimeInterval.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

extension NSTimeInterval {
    
    func timeComponents() -> (hours: Int, minutes: Int, seconds: Int) {
        return (hours: Int(self / 3600), minutes: Int((self / 60) % 60), seconds: Int(self % 60) )
    }
    
    var stringTimeRepresentationStyle1: String {
        let components = self.timeComponents()
        return String(format: "%02dh %02dm %02ds", arguments: [components.0, components.1, components.2])
    }
    
    var stringTimeRepresentationStyle2: String {
        let components = self.timeComponents()
        return String(format: "%02d:%02d:%02d", arguments: [components.0, components.1, components.2])
    }
}