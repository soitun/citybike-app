//
//  CBCoreDataUpdater.swift
//  CityBike
//
//  Created by Tomasz Szulc on 12/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreData
import Model
import CityBikeAPI

class ModelUpdater: CBUpdaterProtocol {
    
    private var syncManager: CBSyncManager!
    
    class var sharedInstance: ModelUpdater {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: ModelUpdater? = nil
        }
        
        dispatch_once(&Static.onceToken, { Static.instance = ModelUpdater() })
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
    
    func setSelectedNetworkIds(ids: [CBNetworkType]) {
        syncManager.setSelectedNetworkIDs(ids)
    }
    
    
    /// MARK: - CBUpdaterProtocol
    func updateNetworks(updatedNetworks: [CBNetwork], completion:() -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            let ctx = CoreDataStack.sharedInstance().createTemporaryContextFromMainContext()
            
            for updatedNetwork in updatedNetworks {
                var network: Network? = Network.fetchWithAttribute("id", value: updatedNetwork.id, context: ctx).first as? Network
                if network == nil {
                    network = Network(context: ctx)
                    network!.location = Location(context: ctx)
                }
                
                network!.fill(updatedNetwork)
                network!.location.fill(updatedNetwork.location)
            }
            
            ctx.save(nil)
            dispatch_async(dispatch_get_main_queue()) { ctx.parentContext?.save(nil) }
            
            completion()
        })
    }
    
    func updateNetworksWithStations(updatedNetworks: [CBNetwork], completion:() -> Void) {        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            let ctx = CoreDataStack.sharedInstance().createTemporaryContextFromMainContext()
            
            for updatedNetwork in updatedNetworks {
                var network: Network? = Network.fetchWithAttribute("id", value: updatedNetwork.id, context: ctx).first as? Network
                if network == nil {
                    network = Network(context: ctx)
                    network!.location = Location(context: ctx)
                }
                
                network!.fill(updatedNetwork)
                network!.location.fill(updatedNetwork.location)
                
                /// stations
                for updatedStation in updatedNetwork.stations {
                    if let station: Station = Station.fetchWithAttribute("id", value: updatedStation.id, context: ctx).first as? Station {
                        station.fill(updatedStation)
                        
                    } else {
                        let station: Station = Station(context: ctx)
                        station.fill(updatedStation)
                        network!.addStation(station)
                    }
                }
            }
            
            ctx.save(nil)
            dispatch_async(dispatch_get_main_queue()) { ctx.parentContext?.save(nil) }
            
            completion()
        })
    }
}

private extension Network {
    func fill(updatedNetwork: CBNetwork) {
        company = updatedNetwork.company ?? ""
        id = updatedNetwork.id
        name = updatedNetwork.name
    }
}

private extension Station {
    func fill(updatedStation: CBStation) {
        freeBikes = updatedStation.freeBikes
        emptySlots = updatedStation.emptySlots
        id = updatedStation.id
        coordinate = updatedStation.coordinate
        name = updatedStation.name
        timestamp = updatedStation.timestamp
    }
}

private extension Location {
    func fill(updatedLocation: CBLocation) {
        city = updatedLocation.city
        country = updatedLocation.country
        coordinate = updatedLocation.coordinate
    }
}
