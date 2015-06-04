//
//  CBStation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreLocation

class CBStation {
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
}