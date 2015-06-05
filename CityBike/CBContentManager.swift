//
//  ModelManager.swift
//  CityBike
//
//  Created by Tomasz Szulc on 05/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBContentManager {
    
    var networks = [CBNetwork]()
    
    /// Get shared instance
    class var sharedInstance: CBContentManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: CBContentManager? = nil
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            Static.instance = CBContentManager()
        })
        
        return Static.instance!
    }

    /// Use to fetch all networks. Do this before fetching stations
    func fetchAllNetworks(completion: (Void -> Void)?) {
        CBService.sharedInstance.fetchNetworks { (networks) -> Void in
            self.networks = networks
            println("Fetched all networks")
            completion?()
        }
    }
    
    /// Fetch stations for specified types
    func fetchStationsForNetworkTypes(types: [CBNetworkType], completion: (stations: [CBStation]) -> Void) {
        CBService.sharedInstance.fetchStationsForNetworkTypes(types, completion: { (results: Dictionary<CBNetworkType, [CBStation]>) -> Void in
            
            var stations = Array<CBStation>()
            for (_, stationsInNetwork) in results {
                stations += stationsInNetwork
            }
            
            completion(stations: stations)
        })
    }
}