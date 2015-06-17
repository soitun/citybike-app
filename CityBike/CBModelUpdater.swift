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
        self.syncManager = CBSyncManager()
        self.syncManager.delegate = self
    }
    
    func start() {
        self.syncManager.start()
    }
    
    func stop() {
        self.syncManager.stop()
    }
    
    func forceUpdate() {
        self.syncManager.forceUpdate()
    }
    
    
    /// MARK: - CBUpdaterProtocol
    func updateNetworks(updatedNetworks: [CBNetwork], completion:() -> Void) {
        println("Sync networks")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let tmpContext = CoreDataHelper.sharedInstance().createTemporaryContextFromMainContext()
            for updatedNetwork in updatedNetworks {
                var network: CDNetwork? = CDNetwork.fetchWithAttribute("id", value: updatedNetwork.id, context: tmpContext).first as? CDNetwork
                if network == nil {
                    network = CDNetwork(context: tmpContext)
                    network!.location = CDLocation(context: tmpContext)
                }
                
                /// network
                self.fillNetwork(network!, updatedNetwork: updatedNetwork)
                
                /// location
                self.fillLocation(network!.location, updatedLocation: updatedNetwork.location)
            }
            
            tmpContext.save(nil)
            tmpContext.parentContext?.save(nil)
            
            completion()
        })
    }
    
    func updateNetworksWithStations(updatedNetworks: [CBNetwork], completion:() -> Void) {
        println("Sync networks and stations")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let tmpContext = CoreDataHelper.sharedInstance().createTemporaryContextFromMainContext()
            
            for updatedNetwork in updatedNetworks {
                var network: CDNetwork? = CDNetwork.fetchWithAttribute("id", value: updatedNetwork.id, context: tmpContext).first as? CDNetwork
                if network == nil {
                    network = CDNetwork(context: tmpContext)
                    network!.location = CDLocation(context: tmpContext)
                }
                
                /// network
                self.fillNetwork(network!, updatedNetwork: updatedNetwork)
                
                /// location
                self.fillLocation(network!.location, updatedLocation: updatedNetwork.location)
                
                /// stations
                for updatedStation in updatedNetwork.stations {
                    if let station = CDStation.fetchWithAttribute("id", value: updatedStation.id, context: tmpContext).first as? CDStation {
                        self.fillStation(station, updatedStation: updatedStation)
                    } else {
                        let station: CDStation = CDStation(context: tmpContext)
                        self.fillStation(station, updatedStation: updatedStation)
                        network!.addStation(station)
                    }
                }
            }
            
            tmpContext.save(nil)
            tmpContext.parentContext?.save(nil)
            
            completion()
        })
    }
    
    private func fillNetwork(network: CDNetwork, updatedNetwork: CBNetwork) {
        network.company = updatedNetwork.company ?? ""
        network.id = updatedNetwork.id
        network.name = updatedNetwork.name
    }
    
    private func fillStation(station: CDStation, updatedStation: CBStation) {
        station.freeBikes = updatedStation.freeBikes
        station.emptySlots = updatedStation.emptySlots
        station.id = updatedStation.id
        station.coordinate = updatedStation.coordinate
        station.name = updatedStation.name
        station.timestamp = updatedStation.timestamp
    }
    
    private func fillLocation(location: CDLocation, updatedLocation: CBLocation) {
        location.city = updatedLocation.city
        location.country = updatedLocation.country
        location.coordinate = updatedLocation.coordinate
    }
}