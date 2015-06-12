//
//  CBCoreDataUpdater.swift
//  CityBike
//
//  Created by Tomasz Szulc on 12/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBModelUpdater: CBUpdaterProtocol {
    
    private var syncManager: CBSyncManager!
    
    class var sharedInstance: CBModelUpdater {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: CBModelUpdater? = nil
        }
        
        dispatch_once(&Static.onceToken, { Static.instance = CBModelUpdater() })
        
        return Static.instance!
    }

    init() {
        self.syncManager = CBSyncManager()
        self.syncManager.delegate = self
    }
    
    
    /// MARK: - CBUpdaterProtocol
    func updateNetworks(networks: [CBNetwork], completion:() -> Void) {
        
    }
    
    func updateNetworksWithStations(networksWithStations: [CBNetwork], completion:() -> Void) {
        
    }
}