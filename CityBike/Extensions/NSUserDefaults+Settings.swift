//
//  CBNSUserDefaults.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
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

extension NSUserDefaults {
    
    private static let CityBikeDisplayedGettingStarted = "CityBikeDisplayedGettingStarted"
    private static let CityBikeSelectedNetworks = "CityBikeSelectedNetworks"
    private static let CityBikeStartRideDate = "CityBikeStartRideDate"
    private static let CityBikeMapRegion = "CityBikeMapRegion"
    
    class func registerCityBikeDefaults() {
        
        let defaults = [
            CityBikeDisplayedGettingStarted: 0,
            CityBikeSelectedNetworks: NSKeyedArchiver.archivedDataWithRootObject([String]())
        ]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
    }
    
    
    /// MARK: Getting Started
    class func getDisplayedGettingStarted() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(CityBikeDisplayedGettingStarted)
    }
    
    class func setDisplayedGettingStarted(displayed: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(displayed, forKey: CityBikeDisplayedGettingStarted)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    /// MARK: Selected Networks
    class func getNetworkIDs() -> [CBNetworkType] {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(CityBikeSelectedNetworks) as! NSData
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String]
    }
    
    class func saveNetworkIDs(ids: [CBNetworkType]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(ids)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: CityBikeSelectedNetworks)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    /// MARK: Ride Time
    class func getStartRideDate() -> NSDate? {
        return NSUserDefaults.standardUserDefaults().objectForKey(CityBikeStartRideDate) as? NSDate
    }
    
    class func setStartRideDate(date: NSDate) {
        NSUserDefaults.standardUserDefaults().setObject(date, forKey: CityBikeStartRideDate)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func removeStartRideDate() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(CityBikeStartRideDate)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    /// MARK: Map Region
    class func getMapRegion() -> MKCoordinateRegion? {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(CityBikeMapRegion) as? NSData {
            let serialized = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! CBCoordinateRegionSerializable
            let center = CLLocationCoordinate2D(latitude: serialized.latitude, longitude: serialized.longitude)
            let span = MKCoordinateSpan(latitudeDelta: serialized.latitudeDelta, longitudeDelta: serialized.longitudeDelta)
            return MKCoordinateRegionMake(center, span)
        } else {
            return nil
        }
    }
    
    class func setMapRegion(region: MKCoordinateRegion) {
        let serialized = CBCoordinateRegionSerializable()
        serialized.latitude = region.center.latitude
        serialized.longitude = region.center.longitude
        serialized.latitudeDelta = region.span.latitudeDelta
        serialized.longitudeDelta = region.span.longitudeDelta
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(serialized)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: CityBikeMapRegion)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}