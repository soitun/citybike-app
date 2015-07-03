//
//  CBStation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreLocation

public class CBStation {
    public var emptySlots: Int
//    var extra: NSDictionary
    public var freeBikes: Int
    public var id: String
    public var name: String
    public var timestamp: NSDate
    public var coordinate: CLLocationCoordinate2D
    
    public init(emptySlots: Int, freeBikes: Int, id: String, coordinate: CLLocationCoordinate2D, name: String, timestamp: NSDate) {
        self.emptySlots = emptySlots
        self.freeBikes = freeBikes
        self.id = id
        self.coordinate = coordinate
        self.name = name
        self.timestamp = timestamp
    }
}