//
//  CBNSTimeInterval.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

extension NSTimeInterval {
    
    private func timeComponents() -> (Int, Int, Int) {
        return (Int(self / 3600), Int((self / 60) % 60), Int(self % 60) )
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