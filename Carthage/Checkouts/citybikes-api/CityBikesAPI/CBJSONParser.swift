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

    private enum Key: String {
        case City = "city"
        case Company = "company"
        case Country = "country"
        case EmptySlots = "empty_slots"
        case FreeBikes = "free_bikes"
        case Href = "href"
        case ID = "id"
        case Latitude = "latitude"
        case Location = "location"
        case Longitude = "longitude"
        case Name = "name"
        case Stations = "stations"
        case Timestamp = "timestamp"
    }
    
    private class Box {
        private let storage: Dictionary<String, AnyObject>
        
        subscript(key: Key) -> AnyObject? {
            get { return storage[key.rawValue] }
        }
        
        init(storage: Dictionary<String, AnyObject>) {
            self.storage = storage
        }
    }
    
    
    private class func validate(json: Box) -> Bool {
        let networkValid = (
            json[Key.Href] != nil &&
            json[Key.ID] != nil &&
            json[Key.Location] != nil &&
            json[Key.Name] != nil &&
            json[Key.Company] != nil /* &&
             json[Key.Stations] != nil*/) /// Do not check stations because /networks request will not work
        
        var locationValid = false
        if networkValid {
            let jsonLocation = Box(storage:json[Key.Location] as! JSON)
            locationValid = (
                jsonLocation[Key.City] != nil &&
                jsonLocation[Key.Country] != nil &&
                jsonLocation[Key.Latitude] != nil &&
                jsonLocation[Key.Longitude] != nil)
        }
        
        return networkValid && locationValid
    }
    
    class func parseNetwork(rawJSON: JSON) -> CBNetwork? {
        var json = Box(storage: rawJSON)
        
        if self.validate(json) == false {
            println("downloaded json is corrupted. \(rawJSON)")
            return nil
        }
        
        var network = CBNetwork()
        
        /// Company might be string or array of strings
        network.company = flattenPossibleStringArray(json[Key.Company]!)
        
        network.href = cast(json[Key.Href])
        network.id = cast(json[Key.ID])
        network.location = parseLocation(Box(storage:json[Key.Location] as! JSON))
        network.name = cast(json[Key.Name])
        
        if let jsonStations = json[Key.Stations] as? [JSON] {
            network.stations = jsonStations.map { self.parseStation(Box(storage:$0)) }
        }
        
        return network
    }
    
    private class func parseLocation(json: Box) -> CBLocation {
        let latitude = CLLocationDegreesFromObject(json[Key.Latitude]!)
        let longitude = CLLocationDegreesFromObject(json[Key.Longitude]!)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return CBLocation(city: cast(json[Key.City]), country: cast(json[Key.Country]), coordinate: coordinate)
    }
    
    private class func parseStation(json: Box) -> CBStation {
        let emptySlots = json[Key.EmptySlots] as? Int ?? 0
        let freeBikes = json[Key.FreeBikes] as? Int ?? 0
        let id = json[Key.ID] as? String ?? ""
        
        let latitude = CLLocationDegreesFromObject(json[Key.Latitude]!)
        let longitude = CLLocationDegreesFromObject(json[Key.Longitude]!)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let name = json[Key.Name] as? String ?? ""
        let timestamp = json[Key.Timestamp] as? NSDate ?? NSDate()
        return CBStation(emptySlots: emptySlots, freeBikes: freeBikes, id: id, coordinate: coordinate, name: name, timestamp: timestamp)
    }
    
    private class func flattenPossibleStringArray(object: AnyObject) -> String {
        if object is NSNull { return "" } /// There should be no nulls in the API!!!
        
        if object is Array<String> {
            return ", ".join(object as! Array<String>)
        }
        return object as! String
    }
    
    private class func cast<T>(obj: AnyObject!) -> T {
        return obj as! T
    }
    
    /// This is needed to parse latitude or longitude which is sometimes String instead of Float
    private class func CLLocationDegreesFromObject(object: AnyObject) -> CLLocationDegrees {
        if object is CLLocationDegrees { return object as! CLLocationDegrees }
        
        if object is String {
            let formatter = NSNumberFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") /// dot as separator in float
            return CLLocationDegrees(formatter.numberFromString(object as! String)!.floatValue)
        }
        
        return 0 /// this shouldn't happen
    }
}