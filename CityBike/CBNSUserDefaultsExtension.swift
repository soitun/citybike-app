//
//  CBNSUserDefaults.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    
    private static let CityBikeDisplayedGettingStarted = "CityBikeDisplayedGettingStarted"
    private static let CityBikeSelectedNetworks = "CityBikeSelectedNetworks"
    private static let CityBikeStartRideTimeInterval = "CityBikeStartRideTimeInterval"
    private static let CityBikeRidesHistory = "CityBikeRidesHistory"
    
    class func registerCityBikeDefaults() {
        
        let defaults = [
            CityBikeDisplayedGettingStarted: 0,
            CityBikeSelectedNetworks: NSKeyedArchiver.archivedDataWithRootObject([String]()),
            CityBikeRidesHistory: NSKeyedArchiver.archivedDataWithRootObject(RidesHistoryArchived())
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
    class func getNetworkIDs() -> [String] {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(CityBikeSelectedNetworks) as! NSData
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String]
    }
    
    class func saveNetworkIDs(ids: [String]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(ids)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: CityBikeSelectedNetworks)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    /// MARK: Ride Time
    class func getStartRideTimeInterval() -> NSTimeInterval? {
        let value = NSUserDefaults.standardUserDefaults().objectForKey(CityBikeStartRideTimeInterval) as? NSTimeInterval
        if value != nil {
            return value
        } else {
            return nil
        }
    }
    
    class func setStartRideTimeInterval(ti: NSTimeInterval) {
        NSUserDefaults.standardUserDefaults().setDouble(ti, forKey: CityBikeStartRideTimeInterval)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func removeStartRideTimeInterval() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(CityBikeStartRideTimeInterval)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /// MARK: Rides History
    class func getRidesHistory() -> RidesHistory {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(CityBikeRidesHistory) as! NSData
        let archivedHistory = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! RidesHistoryArchived
        
        var unarchivedHistory = RidesHistory()
        for (rideDay, archivedRecords) in archivedHistory {
            var unarchiveRecords = [RideRecord]()
            for record in archivedRecords {
                unarchiveRecords.append(NSKeyedUnarchiver.unarchiveObjectWithData(record) as! RideRecord)
            }
            
            unarchivedHistory[rideDay] = unarchiveRecords
        }
        
        return unarchivedHistory
    }
    
    class func setRidesHistory(history: RidesHistory) {
        var historyToStore = RidesHistoryArchived()
        
        for (rideDay, records) in history {
            var archivedRecords = [NSData]()
            for record in records {
                archivedRecords.append(NSKeyedArchiver.archivedDataWithRootObject(record))
            }
            
            historyToStore[rideDay] = archivedRecords
        }
        
        let archivedHistory = NSKeyedArchiver.archivedDataWithRootObject(historyToStore)
        NSUserDefaults.standardUserDefaults().setObject(archivedHistory, forKey: CityBikeRidesHistory)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}