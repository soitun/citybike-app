//
//  CDStation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(CDStation)
class CDStation: NSManagedObject {

    @NSManaged var freeBikes: NSNumber
    @NSManaged var emptySlots: NSNumber
    @NSManaged var id: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var name: String
    @NSManaged var timestamp: String
    @NSManaged var network: CDNetwork

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude.doubleValue, longitude: self.longitude.doubleValue)
    }
    
    
    private class func entityName() -> String {
        return "CDStation"
    }
    
    class func allStations(context: NSManagedObjectContext) -> [CDStation] {
        let request = NSFetchRequest(entityName: self.entityName())
        var stations = context.executeFetchRequest(request, error: nil) as? [CDStation]
        return stations ?? [CDStation]()
    }
    
    class func stationWithID(id: String, context: NSManagedObjectContext) -> CDStation? {
        let request = NSFetchRequest(entityName: self.entityName())
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.executeFetchRequest(request, error: nil)?.first as! CDStation?
    }
    
    func fill(station: CBStation) {
        self.freeBikes = station.freeBikes
        self.emptySlots = station.emptySlots
        self.id = station.id
        self.latitude = station.coordinate.latitude
        self.longitude = station.coordinate.longitude
        self.name = station.name
        self.timestamp = station.timestamp
    }
}
