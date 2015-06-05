//
//  ModelManager.swift
//  CityBike
//
//  Created by Tomasz Szulc on 05/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBContentManager: NSObject {
    
    static let DidUpdateNetworksNotification = "DidUpdateNetworksNotification"
    static let DidUpdateStationsNotification = "DidUpdateStationsNotification"
    
    /// recently received
    var networks = [CBNetwork]()
    var stations = [CBStation]()

    private var networksTimer: NSTimer?
    private var stationsTimer: NSTimer?
    
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
    
    func start() {
        self.refreshNetworks()
        self.refreshStations()
        
        /// Refersh networks every 5 minutes
        self.networksTimer?.invalidate()
        self.networksTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(60), target: self, selector: Selector("refreshNetworks"), userInfo: nil, repeats: true)
        
        self.stationsTimer?.invalidate()
        self.stationsTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(15), target: self, selector: Selector("refreshStations"), userInfo: nil, repeats: true)
    }
    
    func stop() {
        self.networksTimer?.invalidate()
        self.stationsTimer?.invalidate()
    }
    
    func forceStationsUpdate() {
        self.refreshStations()
    }
    
    
    /// MARK: Private
    func refreshNetworks() {
        CBService.sharedInstance.fetchNetworks { (networks, error) -> Void in
            if error == nil {
                println("Fetched all networks")
                self.networks = networks
                NSNotificationCenter.defaultCenter().postNotificationName(CBContentManager.DidUpdateNetworksNotification, object: nil, userInfo: ["networks": networks])
            } else {
                println(error!.localizedDescription)
            }
        }
    }
    
    func refreshStations() {
        let savedTypes = NSUserDefaults.getNetworkIDs() as [String]
        var types = [CBNetworkType]()
        for savedType in savedTypes {
            types.append(CBNetworkType(rawValue: savedType)!)
        }
        
        if types.count > 0 {
            CBService.sharedInstance.fetchStationsForNetworkTypes(types, completion: { (results: Dictionary<CBNetworkType, [CBStation]>, error: NSError?) -> Void in
                if error == nil {
                    println("Fetched selected stations")

                    /// collect stations from every network
                    var stations = Array<CBStation>()
                    for (_, stationsInNetwork) in results {
                        stations += stationsInNetwork
                    }
                    
                    self.stations = stations
                    self.postStationUpdate(stations)
                } else {
                    println(error!.localizedDescription)
                }
            })
        } else {
            self.stations = [CBStation]()
            self.postStationUpdate(self.stations)
        }
    }
    
    private func postStationUpdate(stations: [CBStation]) {
        NSNotificationCenter.defaultCenter().postNotificationName(CBContentManager.DidUpdateStationsNotification, object: nil, userInfo: ["stations": stations])
    }
}