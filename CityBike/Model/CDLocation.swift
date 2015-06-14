//
//  CDLocation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreData

@objc(CDLocation)
class CDLocation: NSManagedObject {

    @NSManaged var city: String
    @NSManaged var country: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var network: CDNetwork

    func fill(location: CBLocation) {
        self.city = location.city
        self.country = location.country
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}
