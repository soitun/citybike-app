//
//  CBStation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreLocation

class CBStation: NSObject, NSCopying {
    var emptySlots: Int!
//    var extra: NSDictionary
    var freeBikes: Int!
    var id: String!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var name: String!
    var timestamp: String!
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.latitude, self.longitude)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        var copy = CBStation()
        copy.emptySlots = self.emptySlots
        copy.freeBikes = self.freeBikes
        copy.id = self.id
        copy.latitude = self.latitude
        copy.longitude = self.longitude
        copy.name = self.name
        copy.timestamp = self.timestamp
        return copy
    }
}