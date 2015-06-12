//
//  CBScheduledDownloader.swift
//  CityBike
//
//  Created by Tomasz Szulc on 12/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

protocol CBScheduledDownloaderDelegate {
    func cbdownloaderDidDownloadNetworks(networks: [CBNetwork]?, error: NSError?)
    func cbdownloaderDidDownloadNetworksWithStations(networksAndStations: [CBNetwork]?, error: NSError?)
}

class CBScheduledDownloader: NSObject {
    
    var delegate: CBScheduledDownloaderDelegate?
    
    private var networskDownloaderTimer: NSTimer?
    private var stationsDownloaderTimer: NSTimer?
    private var wasConnectionProblem = false
    
    
    func start() {
        self.scheduleNetworksTimer(60)
        self.scheduleStationsTimer(15)
        
        self.refreshNetworks()
        self.refreshStations()
    }
    
    func stop() {
        self.networskDownloaderTimer?.invalidate()
        self.stationsDownloaderTimer?.invalidate()
    }
    
    func forceStationsUpdate() {
        self.refreshStations()
    }
    
    
    /// MARK: Private
    private func scheduleNetworksTimer(interval: NSTimeInterval) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.networskDownloaderTimer?.invalidate()
            self.networskDownloaderTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("refreshNetworks"), userInfo: nil, repeats: true)
        })
    }
    
    private func scheduleStationsTimer(interval: NSTimeInterval) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.stationsDownloaderTimer?.invalidate()
            self.stationsDownloaderTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("refreshStations"), userInfo: nil, repeats: true)
        })
    }
    
    func refreshNetworks() {
        CBService.sharedInstance.fetchNetworks { (networks, error) -> Void in
            println("Fetched networks")
            self.delegate?.cbdownloaderDidDownloadNetworks(networks, error: error)
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

                    self.delegate?.cbdownloaderDidDownloadNetworksWithStations(results, error: error)
                    
                    if self.wasConnectionProblem == true {
                        self.wasConnectionProblem == false
                        self.scheduleStationsTimer(15)
                    }
                } else {
                    println(error!.localizedDescription)
                    if self.wasConnectionProblem == false {
                        self.wasConnectionProblem = true
                        self.scheduleStationsTimer(3)
                    }
                }
            })
        } else {
            /// do nothing?
        }
    }
}