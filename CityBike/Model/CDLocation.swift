//
//  CDLocation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

@objc(CDLocation)
public class CDLocation: NSManagedObject {

    @NSManaged public var city: String
    @NSManaged public var country: String
    @NSManaged public var network: CDNetwork
    
    @NSManaged private var latitudeValue: NSNumber
    @NSManaged private var longitudeValue: NSNumber
    
    public var coordinate: CLLocationCoordinate2D {
        set {
            self.latitudeValue = newValue.latitude
            self.longitudeValue = newValue.longitude
        }
        
        get {
            return CLLocationCoordinate2D(latitude: self.latitudeValue.doubleValue, longitude: self.longitudeValue.doubleValue)
        }
    }
}
