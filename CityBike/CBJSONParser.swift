//
//  CBJSONParser.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreLocation

class CBJSONParser {
    
    typealias JSON = Dictionary<String, AnyObject>
    
    class func parseNetwork(json: JSON) -> CBNetwork {
        var network = CBNetwork()
        network.company = json["company"] as! String
        network.href = json["href"] as! String
        network.id = json["id"] as! String
        network.location = self.parseLocation(json["location"] as! JSON)
        network.name = json["name"] as! String
        
        for stationJSON in json["stations"] as! [JSON] {
            let station = self.parseStation(stationJSON)
            network.stations.append(station)
        }
        
        return network
    }
    
    private class func parseLocation(json: JSON) -> CBLocation {
        var location = CBLocation()
        location.city = json["city"] as! String
        location.country = json["country"] as! String
        location.latitude = json["latitude"] as! CLLocationDegrees
        location.longitude = json["longitude"] as! CLLocationDegrees
        return location
    }
    
    private class func parseStation(json: JSON) -> CBStation {
        var station = CBStation()
        station.emptySlots = json["empty_slots"] as! Int
        station.freeBikes = json["free_bikes"] as! Int
        station.id = json["id"] as! String
        station.latitude = json["latitude"] as! CLLocationDegrees
        station.longitude = json["longitude"] as! CLLocationDegrees
        station.name = json["name"] as! String
        station.timestamp = json["timestamp"] as! String
        return station
    }
}