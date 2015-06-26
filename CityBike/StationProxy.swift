//
//  StationProxy.swift
//  CityBike
//
//  Created by Tomasz Szulc on 26/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreLocation
import Model

class StationProxy {
    var id: String
    var freeBikes: Int
    var totalSlots: Int
    var coordinate: CLLocationCoordinate2D
    
    init(id: String, freeBikes: Int, totalSlots: Int, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.freeBikes = freeBikes
        self.totalSlots = totalSlots
        self.coordinate = coordinate
    }
}