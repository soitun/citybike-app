//
//  CBUserDefaults.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit
import CityBikeAPI

class UserSettings {
    
    private var userDefaults: NSUserDefaults
    
    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
    }
    
    
    // MARK: Singleton
    private struct Static {
        static var instance: UserSettings!
    }
    
    class func setSharedInstance(instance: UserSettings) {
        Static.instance = instance
    }
    
    class func sharedInstance() -> UserSettings {
        return Static.instance
    }
    
    
    // MARK: Methods
    func registerDefaults() {
        let defaults = [
            CityBikeDisplayedGettingStarted: 0,
            CityBikeSelectedNetworks: NSKeyedArchiver.archivedDataWithRootObject([String]())
        ]
        
        userDefaults.registerDefaults(defaults)
    }
    
    
    // MARK: Getting Started
    private let CityBikeDisplayedGettingStarted = "CityBikeDisplayedGettingStarted"
    func getDisplayedGettingStarted() -> Bool {
        return userDefaults.boolForKey(CityBikeDisplayedGettingStarted)
    }
    
    func setDisplayedGettingStarted(displayed: Bool) {
        userDefaults.setBool(displayed, forKey: CityBikeDisplayedGettingStarted)
        userDefaults.synchronize()
    }
    
    
    // MARK: Selected Networks
    private let CityBikeSelectedNetworks = "CityBikeSelectedNetworks"
    func getNetworkIDs() -> [CBNetworkType] {
        if let data = userDefaults.objectForKey(CityBikeSelectedNetworks) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [CBNetworkType]
        } else {
            return [CBNetworkType]()
        }
    }
    
    func saveNetworkIDs(ids: [CBNetworkType]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(ids)
        userDefaults.setObject(data, forKey: CityBikeSelectedNetworks)
        userDefaults.synchronize()
    }
    
    
    // MARK: Ride Tracking
    private let CityBikeStartRideDate = "CityBikeStartRideDate"
    func getStartRideDate() -> NSDate? {
        return userDefaults.objectForKey(CityBikeStartRideDate) as? NSDate
    }
    
    func setStartRideDate(date: NSDate) {
        userDefaults.setObject(date, forKey: CityBikeStartRideDate)
        userDefaults.synchronize()
    }
    
    func removeStartRideDate() {
        userDefaults.removeObjectForKey(CityBikeStartRideDate)
        userDefaults.synchronize()
    }
    
    
    // MARK: Map Region
    private let CityBikeMapRegion = "CityBikeMapRegion"
    func getMapRegion() -> MKCoordinateRegion? {
        if let data = userDefaults.objectForKey(CityBikeMapRegion) as? NSData {
            let serialized = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! CoordinateRegionSerializable
            let center = CLLocationCoordinate2D(latitude: serialized.latitude, longitude: serialized.longitude)
            let span = MKCoordinateSpan(latitudeDelta: serialized.latitudeDelta, longitudeDelta: serialized.longitudeDelta)
            return MKCoordinateRegionMake(center, span)
        } else {
            return nil
        }
    }
    
    func setMapRegion(region: MKCoordinateRegion) {
        let serialized = CoordinateRegionSerializable()
        serialized.latitude = region.center.latitude
        serialized.longitude = region.center.longitude
        serialized.latitudeDelta = region.span.latitudeDelta
        serialized.longitudeDelta = region.span.longitudeDelta
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(serialized)
        userDefaults.setObject(data, forKey: CityBikeMapRegion)
        userDefaults.synchronize()
    }    
}
