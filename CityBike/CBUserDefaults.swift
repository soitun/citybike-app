//
//  CBUserDefaults.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit

class CBCoordinateRegionSerializable: NSObject, NSCoding {
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var latitudeDelta: CLLocationDegrees = 0
    var longitudeDelta: CLLocationDegrees = 0
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(self.latitude, forKey: "latitude")
        aCoder.encodeDouble(self.longitude, forKey: "longitude")
        aCoder.encodeDouble(self.latitudeDelta, forKey: "latitudeDelta")
        aCoder.encodeDouble(self.longitudeDelta, forKey: "longitudeDelta")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeDoubleForKey("latitude")
        self.longitude = aDecoder.decodeDoubleForKey("longitude")
        self.latitudeDelta = aDecoder.decodeDoubleForKey("latitudeDelta")
        self.longitudeDelta = aDecoder.decodeDoubleForKey("longitudeDelta")
    }
    
    override init() { super.init() }
}

class CBUserDefaults: NSUserDefaults {
        
    private class func createSharedDefaults() -> CBUserDefaults {
        return CBUserDefaults(suiteName: CBConstant.AppSharedGroup.rawValue)!
    }
    
    class var sharedInstance: CBUserDefaults {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: CBUserDefaults? = nil
        }
        
        dispatch_once(&Static.onceToken, { Static.instance = CBUserDefaults.createSharedDefaults() })
        return Static.instance!
    }

    
    private let CityBikeDisplayedGettingStarted = "CityBikeDisplayedGettingStarted"
    private let CityBikeSelectedNetworks = "CityBikeSelectedNetworks"
    private let CityBikeStartRideDate = "CityBikeStartRideDate"
    private let CityBikeMapRegion = "CityBikeMapRegion"
    
    func registerCityBikeDefaults() {
        
        let defaults = [
            CityBikeDisplayedGettingStarted: 0,
            CityBikeSelectedNetworks: NSKeyedArchiver.archivedDataWithRootObject([String]())
        ]
        self.registerDefaults(defaults)
    }
    
    
    /// MARK: Getting Started
    func getDisplayedGettingStarted() -> Bool {
        return self.boolForKey(CityBikeDisplayedGettingStarted)
    }
    
    func setDisplayedGettingStarted(displayed: Bool) {
        self.setBool(displayed, forKey: CityBikeDisplayedGettingStarted)
        self.synchronize()
    }
    
    
    /// MARK: Selected Networks
    func getNetworkIDs() -> [CBNetworkType] {
        let data = self.objectForKey(CityBikeSelectedNetworks) as! NSData
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String]
    }
    
    func saveNetworkIDs(ids: [CBNetworkType]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(ids)
        self.setObject(data, forKey: CityBikeSelectedNetworks)
        self.synchronize()
    }
    
    
    /// MARK: Ride Time
    func getStartRideDate() -> NSDate? {
        return self.objectForKey(CityBikeStartRideDate) as? NSDate
    }
    
    func setStartRideDate(date: NSDate) {
        self.setObject(date, forKey: CityBikeStartRideDate)
        self.synchronize()
    }
    
    func removeStartRideDate() {
        self.removeObjectForKey(CityBikeStartRideDate)
        self.synchronize()
    }
    
    
    /// MARK: Map Region
    func getMapRegion() -> MKCoordinateRegion? {
        if let data = self.objectForKey(CityBikeMapRegion) as? NSData {
            let serialized = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! CBCoordinateRegionSerializable
            let center = CLLocationCoordinate2D(latitude: serialized.latitude, longitude: serialized.longitude)
            let span = MKCoordinateSpan(latitudeDelta: serialized.latitudeDelta, longitudeDelta: serialized.longitudeDelta)
            return MKCoordinateRegionMake(center, span)
        } else {
            return nil
        }
    }
    
    func setMapRegion(region: MKCoordinateRegion) {
        let serialized = CBCoordinateRegionSerializable()
        serialized.latitude = region.center.latitude
        serialized.longitude = region.center.longitude
        serialized.latitudeDelta = region.span.latitudeDelta
        serialized.longitudeDelta = region.span.longitudeDelta
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(serialized)
        self.setObject(data, forKey: CityBikeMapRegion)
        self.synchronize()
    }
}