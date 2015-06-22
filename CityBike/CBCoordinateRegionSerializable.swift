//
//  CBCoordinateRegionSerializable.swift
//  CityBike
//
//  Created by Tomasz Szulc on 22/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit

class CBCoordinateRegionSerializable: NSObject, NSCoding {
    
    private let kLatitude = "latitude"
    private let kLongitude = "longitude"
    private let kLatitudeDelta = "latitudeDelta"
    private let kLongitudeDelta = "longitudeDelta"
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var latitudeDelta: CLLocationDegrees = 0
    var longitudeDelta: CLLocationDegrees = 0
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(self.latitude, forKey: kLatitude)
        aCoder.encodeDouble(self.longitude, forKey: kLongitude)
        aCoder.encodeDouble(self.latitudeDelta, forKey: kLatitudeDelta)
        aCoder.encodeDouble(self.longitudeDelta, forKey: kLongitudeDelta)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeDoubleForKey(kLatitude)
        self.longitude = aDecoder.decodeDoubleForKey(kLongitude)
        self.latitudeDelta = aDecoder.decodeDoubleForKey(kLatitudeDelta)
        self.longitudeDelta = aDecoder.decodeDoubleForKey(kLongitudeDelta)
    }
    
    override init() { super.init() }
}