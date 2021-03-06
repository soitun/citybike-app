//
//  CBStationProxy.swift
//  CityBike
//
//  Created by Tomasz Szulc on 23/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import Model

class WatchStationProxy {
    private let station: Station
    var distanceToUser: CLLocationDistance?
    
    var freeBikes: Int { return station.freeBikes.integerValue }
    var emptySlots: Int { return station.emptySlots.integerValue }
    var allSlots: Int { return freeBikes + emptySlots }
    var name: String { return station.name }
    var updateTimestamp: NSDate { return station.timestamp }
    var coordinate: CLLocationCoordinate2D { return station.coordinate }
    
    init(station: Station) {
        self.station = station
    }
}