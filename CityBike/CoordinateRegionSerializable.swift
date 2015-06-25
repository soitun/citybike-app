//
//  CoordinateRegionSerializable.swift
//  CityBike
//
//  Created by Tomasz Szulc on 22/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit

class CoordinateRegionSerializable: NSObject, NSCoding {
    
    private let kLatitude = "latitude"
    private let kLongitude = "longitude"
    private let kLatitudeDelta = "latitudeDelta"
    private let kLongitudeDelta = "longitudeDelta"
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var latitudeDelta: CLLocationDegrees = 0
    var longitudeDelta: CLLocationDegrees = 0
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(latitude, forKey: kLatitude)
        aCoder.encodeDouble(longitude, forKey: kLongitude)
        aCoder.encodeDouble(latitudeDelta, forKey: kLatitudeDelta)
        aCoder.encodeDouble(longitudeDelta, forKey: kLongitudeDelta)
    }
    
    required init(coder aDecoder: NSCoder) {
        latitude = aDecoder.decodeDoubleForKey(kLatitude)
        longitude = aDecoder.decodeDoubleForKey(kLongitude)
        latitudeDelta = aDecoder.decodeDoubleForKey(kLatitudeDelta)
        longitudeDelta = aDecoder.decodeDoubleForKey(kLongitudeDelta)
    }
    
    override init() { super.init() }
}