//
//  CDNetwork.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreData

@objc(CDNetwork)
class CDNetwork: NSManagedObject {

    @NSManaged var company: String
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var location: CDLocation
    @NSManaged var stations: NSSet

    private class func entityName() -> String {
        return "CDNetwork"
    }
    
    class func allNetworks(context: NSManagedObjectContext) -> [CDNetwork] {
        let request = NSFetchRequest(entityName: self.entityName())
        var stations = context.executeFetchRequest(request, error: nil) as? [CDNetwork]
        return stations ?? [CDNetwork]()
    }
    
    class func networkWithID(id: String, context: NSManagedObjectContext) -> CDNetwork? {
        let request = NSFetchRequest(entityName: self.entityName())
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.executeFetchRequest(request, error: nil)?.first as! CDNetwork?
    }
    
    func addStation(station: CDStation) {
        var mutableStations = NSMutableSet(set: self.stations as Set<NSObject>, copyItems: false)
        mutableStations.addObject(station)
        self.stations = NSSet(set: mutableStations as Set<NSObject>, copyItems: false)
    }
    
    func fill(network: CBNetwork) {
        self.company = network.company ?? ""
        self.id = network.id
        self.name = network.name
    }
}
