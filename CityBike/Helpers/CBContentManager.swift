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
    private var wasConnectionProblem = false
    
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
        self.scheduleNetworksTimer(60)
        self.scheduleStationsTimer(15)
        
        self.refreshNetworks()
        self.refreshStations()
    }
    
    func stop() {
        self.networksTimer?.invalidate()
        self.stationsTimer?.invalidate()
    }
    
    func forceStationsUpdate() {
        self.refreshStations()
    }
    
    
    /// MARK: Private
    private func scheduleNetworksTimer(interval: NSTimeInterval) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.networksTimer?.invalidate()
            self.networksTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("refreshNetworks"), userInfo: nil, repeats: true)
        })
    }
    
    private func scheduleStationsTimer(interval: NSTimeInterval) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.stationsTimer?.invalidate()
            self.stationsTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("refreshStations"), userInfo: nil, repeats: true)
        })
    }
    
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
            CBService.sharedInstance.fetchNetworksWithStationsForNetworkTypes(types, completion: { (results: [CBNetwork], error: NSError?) -> Void in
                if error == nil {
                    println("Fetched selected stations")

                    /// collect stations from every network
                    var stations = Array<CBStation>()
                    for network in results {
                        stations += network.stations
                    }
                    
                    self.stations = stations
                    self.postStationUpdate(stations, error: nil)
                    
                    if self.wasConnectionProblem == true {
                        self.wasConnectionProblem == false
                        self.scheduleStationsTimer(15)
                    }
                } else {
                    println(error!.localizedDescription)
                    self.stations = [CBStation]()
                    self.postStationUpdate(self.stations, error: error)
                    
                    if self.wasConnectionProblem == false {
                        self.wasConnectionProblem = true
                        self.scheduleStationsTimer(3)
                    }
                }
            })
        } else {
            self.stations = [CBStation]()
            self.postStationUpdate(self.stations, error: nil)
        }
    }
    
    private func postStationUpdate(stations: [CBStation], error: NSError?) {
        var userInfo: [String: AnyObject] = ["stations": stations]
        if let error = error {
            userInfo["error"] = error
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(CBContentManager.DidUpdateStationsNotification, object: nil, userInfo: userInfo)
    }
}