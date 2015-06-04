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
        
        /// Company might be string or array of strings
        if let company: AnyObject = json["company"] {
            if company is Array<String> {
                network.company = ", ".join(company as! Array<String>)
            } else if company is String {
                network.company = (company as! String)
            }
        }
        
        network.href = json["href"] as! String
        network.id = json["id"] as! String
        network.location = self.parseLocation(json["location"] as! JSON)
        network.name = json["name"] as! String
        
        if let jsonStations = json["stations"] as? [JSON] {
            for jsonStation in jsonStations {
                let station = self.parseStation(jsonStation)
                network.stations.append(station)
            }
        }
        
        return network
    }
    
    private class func parseLocation(json: JSON) -> CBLocation {
        var location = CBLocation()
        location.city = json["city"] as! String
        location.country = json["country"] as! String
        location.latitude = CLLocationDegreesFromObject(json["latitude"]!)
        location.longitude = CLLocationDegreesFromObject(json["longitude"]!)
        return location
    }
    
    private class func parseStation(json: JSON) -> CBStation {
        var station = CBStation()
        station.emptySlots = json["empty_slots"] as! Int
        station.freeBikes = json["free_bikes"] as! Int
        station.id = json["id"] as! String
        station.latitude = CLLocationDegreesFromObject(json["latitude"]!)
        station.longitude = CLLocationDegreesFromObject(json["longitude"]!)
        station.name = json["name"] as! String
        station.timestamp = json["timestamp"] as! String
        return station
    }
    
    /// This is needed to parse latitude or longitude which is sometimes String instead of Float
    private class func CLLocationDegreesFromObject(object: AnyObject) -> CLLocationDegrees {
        if object is String {
            let formatter = NSNumberFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") /// dot as separator in float
            return CLLocationDegrees(formatter.numberFromString(object as! String)!.floatValue)
        } else if object is CLLocationDegrees {
            return object as! CLLocationDegrees
        }
        
        return 0 /// this shouldn't happen
    }
}