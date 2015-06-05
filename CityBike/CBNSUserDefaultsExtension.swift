//
//  CBNSUserDefaults.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    
    private static let CityBikeNetworks = "CityBikeNetworks"
    private static let CityBikeDoNotShowAgainNoBikeNetworks = "CityBikeDoNotShowAgainNoBikeNetworks"
    
    class func registerCityBikeDefaults() {
        let defaults = [
            CityBikeNetworks: NSKeyedArchiver.archivedDataWithRootObject([String]()),
            CityBikeDoNotShowAgainNoBikeNetworks: 0
        ]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
    }
    
    
    
    class func getNetworkIDs() -> [String] {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(CityBikeNetworks) as! NSData
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String]
    }
    
    class func saveNetworkIDs(networks: [String]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(networks)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: CityBikeNetworks)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    
    class func getDoNotShowAgainNoBikeNetworks() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(CityBikeDoNotShowAgainNoBikeNetworks)
    }
    
    class func setDoNotShowAgainNoBikeNetworks(doNotShow: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(doNotShow, forKey: CityBikeDoNotShowAgainNoBikeNetworks)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}