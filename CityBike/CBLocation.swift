//
//  CBLocation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 05/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreLocation

class CBLocation {
    var city: String!
    var country: String!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.latitude, self.longitude)
    }
    
    func copy() -> CBLocation {
        var obj = CBLocation()
        obj.city = self.city
        obj.country = self.country
        obj.latitude = self.latitude
        obj.longitude = self.longitude
        return obj
    }
}