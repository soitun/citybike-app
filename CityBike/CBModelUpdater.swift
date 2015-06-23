//
//  CBCoreDataUpdater.swift
//  CityBike
//
//  Created by Tomasz Szulc on 12/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreData
import CBModel

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
        syncManager = CBSyncManager()
        syncManager.delegate = self
    }
    
    func start() {
        syncManager.start()
    }
    
    func stop() {
        syncManager.stop()
    }
    
    func forceUpdate() {
        syncManager.forceUpdate()
    }
    
    
    /// MARK: - CBUpdaterProtocol
    func updateNetworks(updatedNetworks: [CBNetwork], completion:() -> Void) {
        println("Sync networks")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            let ctx = CoreDataStack.sharedInstance().createTemporaryContextFromMainContext()
            
            for updatedNetwork in updatedNetworks {
                var network: CDNetwork? = CDNetwork.fetchWithAttribute("id", value: updatedNetwork.id, context: ctx).first as? CDNetwork
                if network == nil {
                    network = CDNetwork(context: ctx)
                    network!.location = CDLocation(context: ctx)
                }
                
                network!.fill(updatedNetwork)
                network!.location.fill(updatedNetwork.location)
            }
            
            ctx.save(nil)
            ctx.parentContext?.save(nil)
            
            completion()
            self.sendContentUpdateMessageUsingWormhole()
        })
    }
    
    func updateNetworksWithStations(updatedNetworks: [CBNetwork], completion:() -> Void) {
        println("Sync networks and stations")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            let ctx = CoreDataStack.sharedInstance().createTemporaryContextFromMainContext()
            
            for updatedNetwork in updatedNetworks {
                var network: CDNetwork? = CDNetwork.fetchWithAttribute("id", value: updatedNetwork.id, context: ctx).first as? CDNetwork
                if network == nil {
                    network = CDNetwork(context: ctx)
                    network!.location = CDLocation(context: ctx)
                }
                
                network!.fill(updatedNetwork)
                network!.location.fill(updatedNetwork.location)
                
                /// stations
                for updatedStation in updatedNetwork.stations {
                    if let station: CDStation = CDStation.fetchWithAttribute("id", value: updatedStation.id, context: ctx).first as? CDStation {
                        station.fill(updatedStation)
                        
                    } else {
                        let station: CDStation = CDStation(context: ctx)
                        station.fill(updatedStation)
                        network!.addStation(station)
                    }
                }
            }
            
            ctx.save(nil)
            ctx.parentContext?.save(nil)
            
            completion()
            self.sendContentUpdateMessageUsingWormhole()
        })
    }
    
    func sendContentUpdateMessageUsingWormhole() {
        CBWormhole.sharedInstance.passMessageObject(nil, identifier: CBWormholeNotification.ContentUpdate.rawValue)
    }
}

private extension CDNetwork {
    func fill(updatedNetwork: CBNetwork) {
        company = updatedNetwork.company ?? ""
        id = updatedNetwork.id
        name = updatedNetwork.name
    }
}

private extension CDStation {
    func fill(updatedStation: CBStation) {
        freeBikes = updatedStation.freeBikes
        emptySlots = updatedStation.emptySlots
        id = updatedStation.id
        coordinate = updatedStation.coordinate
        name = updatedStation.name
        timestamp = updatedStation.timestamp
    }
}

private extension CDLocation {
    func fill(updatedLocation: CBLocation) {
        city = updatedLocation.city
        country = updatedLocation.country
        coordinate = updatedLocation.coordinate
    }
}
