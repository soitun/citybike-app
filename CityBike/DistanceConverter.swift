//
//  DistanceConverter.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/07/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit

struct DistanceConverter {
    let meters: Float

    var km: Float {
        return meters / 1000.0
    }
    
    var mi: Float {
        return km * 0.621371
    }
    
    init(_ meters: Float) {
        self.meters = meters
    }
    
    init(_ meters: CLLocationDistance) {
        self.meters = Float(meters)
    }
}