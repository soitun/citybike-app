//
//  CBSyncManager.swift
//  CityBike
//
//  Created by Tomasz Szulc on 12/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

protocol CBUpdaterProtocol {
    func updateNetworks(networks: [CBNetwork], completion:() -> Void)
    func updateNetworksWithStations(networksWithStations: [CBNetwork], completion:() -> Void)
}

class CBSyncManager: CBScheduledDownloaderDelegate {
    
    static let DidUpdateNetworksNotification = "DidUpdateNetworksNotification"
    static let DidUpdateStationsNotification = "DidUpdateStationsNotification"
    
    var delegate: CBUpdaterProtocol?
    
    private var downloader = CBScheduledDownloader()
        
    func start() {
        downloader.delegate = self
        downloader.start()
    }
    
    func stop() {
        downloader.stop()
    }
    
    
    /// MARK: - CBScheduledDownloaderDelegate
    func cbdownloaderDidDownloadNetworks(networks: [CBNetwork]?, error: NSError?) {
        if error == nil {
            self.delegate?.updateNetworks(networks!, completion: { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(CBContentManager.DidUpdateNetworksNotification, object: nil, userInfo: nil)
                })
            })
        }
    }
    
    func cbdownloaderDidDownloadNetworksWithStations(networksAndStations: [CBNetwork]?, error: NSError?) {
        if error == nil {
            self.delegate?.updateNetworksWithStations(networksAndStations!, completion: { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(CBContentManager.DidUpdateStationsNotification, object: nil, userInfo: nil)
                })
            })
        }
    }
}