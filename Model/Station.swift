//
//  Station.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

public typealias StationID = String

@objc(Station)
public class Station: NSManagedObject {

    @NSManaged public var freeBikes: NSNumber
    @NSManaged public var emptySlots: NSNumber
    @NSManaged public var id: StationID
    @NSManaged public var name: String
    @NSManaged public var timestamp: NSDate
    @NSManaged public var network: Network

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
