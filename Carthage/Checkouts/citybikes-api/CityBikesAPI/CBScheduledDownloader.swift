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

extension CBScheduledDownloader {
    private enum RefreshTime: NSTimeInterval {
        case Networks = 30.0
        case Stations = 15.0
        case Fast = 3.0
    }
    
    private enum Timer {
        case Networks, Stations
    }
}

class CBScheduledDownloader: NSObject {
    
    var delegate: CBScheduledDownloaderDelegate?
    var selectedNetworkIDs = [CBNetworkType]()

    private var networskDownloaderTimer: NSTimer?
    private var stationsDownloaderTimer: NSTimer?
    private var connectionProblem = false
    
    func start() {
        scheduleTimer(.Networks, refreshTime: .Networks)
        scheduleTimer(.Stations, refreshTime: .Stations)
        
        refreshNetworks()
        refreshStations()
    }
    
    func stop() {
        stopTimer(.Networks)
        stopTimer(.Stations)
    }
    
    func forceStationsUpdate() {
        refreshStations()
    }
    
    
    /// MARK: Refreshing
    func refreshNetworks() {
        CBService.sharedInstance.fetchNetworks { (networks, error) -> Void in
            if let error = error {
                self.connectionProblem = true
                println(error.localizedDescription)
                self.scheduleTimer(.Networks, refreshTime: .Fast)
                
            } else {
                if self.connectionProblem {
                    self.connectionProblem = false
                    self.scheduleTimer(.Networks, refreshTime: .Networks)
                }
            }
            
            self.delegate?.cbdownloaderDidDownloadNetworks(networks, error: error)
        }
    }
    
    func refreshStations() {
        if selectedNetworkIDs.count > 0 {
            CBService.sharedInstance.fetchNetworksWithStationsForNetworkTypes(selectedNetworkIDs, completion: { (results: [CBNetwork], error: NSError?) -> Void in
                if let error = error {
                    self.connectionProblem = true
                    println(error.localizedDescription)
                    self.scheduleTimer(.Stations, refreshTime: .Fast)
                    
                } else {
                    if self.connectionProblem {
                        self.connectionProblem = false
                        self.scheduleTimer(.Stations, refreshTime: .Stations)
                    }
                }
                
                self.delegate?.cbdownloaderDidDownloadNetworksWithStations(results, error: error)
            })
        } else {
            /// do nothing?
        }
    }
    
    
    /// MARK: Private
    private func scheduleTimer(timer: Timer, refreshTime: RefreshTime) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            switch timer {
            case .Networks:
                self.networskDownloaderTimer?.invalidate()
                self.networskDownloaderTimer = self.scheduleTimer(refreshTime, sel: Selector("refreshNetworks"))
                
            case .Stations:
                self.stationsDownloaderTimer?.invalidate()
                self.stationsDownloaderTimer = self.scheduleTimer(refreshTime, sel: Selector("refreshStations"))
            }
        })
    }
    
    private func stopTimer(timer: Timer) {
        switch timer {
        case .Networks: networskDownloaderTimer?.invalidate()
        case .Stations: stationsDownloaderTimer?.invalidate()
        }
    }
    
    private func scheduleTimer(refreshTime: RefreshTime, sel: Selector) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(refreshTime.rawValue, target: self, selector: sel, userInfo: nil, repeats: true)
    }
    
}