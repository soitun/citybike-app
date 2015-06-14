//
//  CBCoreDataUpdater.swift
//  CityBike
//
//  Created by Tomasz Szulc on 12/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreData

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
    
    func start() {
        self.syncManager.start()
    }
    
    func stop() {
        self.syncManager.stop()
    }
    
    
    /// MARK: - CBUpdaterProtocol
    func updateNetworks(updatedNetworks: [CBNetwork], completion:() -> Void) {
        println("Sync networks")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let tmpContext = CoreDataHelper.temporaryContext
            for updatedNetwork in updatedNetworks {
                var network: CDNetwork? = CDNetwork.networkWithID(updatedNetwork.id, context: tmpContext)
                if network == nil {
                    network = CDNetwork.create(tmpContext)
                    network!.location = CDLocation.create(tmpContext)
                }
                
                /// network
                network!.fill(updatedNetwork)
                
                /// location
                network!.location.fill(updatedNetwork.location)
            }
            
            tmpContext.save(nil)
            tmpContext.parentContext?.save(nil)
            
            completion()
        })
    }
    
    func updateNetworksWithStations(updatedNetworks: [CBNetwork], completion:() -> Void) {
        println("Sync networks and stations")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let tmpContext = CoreDataHelper.temporaryContext
            
            for updatedNetwork in updatedNetworks {
                var network: CDNetwork? = CDNetwork.networkWithID(updatedNetwork.id, context: tmpContext)
                if network == nil {
                    network = CDNetwork.create(tmpContext)
                    network!.location = CDLocation.create(tmpContext)
                }
                
                /// network
                network!.fill(updatedNetwork)
                
                /// location
                network!.location.fill(updatedNetwork.location)
                
                /// stations
                for updatedStation in updatedNetwork.stations {
                    if let station = CDStation.stationWithID(updatedStation.id, context: tmpContext) {
                        station.fill(updatedStation)
                    } else {
                        let station: CDStation = CDStation.create(tmpContext)
                        station.fill(updatedStation)
                        network!.addStation(station)
                    }
                }
            }
            
            tmpContext.save(nil)
            tmpContext.parentContext?.save(nil)
            
            completion()
        })
    }
}