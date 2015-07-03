//
//  CBSyncManager.swift
//  CityBike
//
//  Created by Tomasz Szulc on 12/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

public enum CBSyncManagerNotification: String {
    case DidUpdateNetworks = "DidUpdateNetworks"
    case DidUpdateStations = "DidUpdateStations"
}

public protocol CBUpdaterProtocol {
    func updateNetworks(networks: [CBNetwork], completion:() -> Void)
    func updateNetworksWithStations(networksWithStations: [CBNetwork], completion:() -> Void)
}

public class CBSyncManager: CBScheduledDownloaderDelegate {
    
    public var delegate: CBUpdaterProtocol?
    
    private var _started: Bool = false
    
    public var started: Bool {
        return _started
    }
    
    private var downloader = CBScheduledDownloader()
    
    public init() {}
    
    public func start() {
        if _started { return }
        
        downloader.delegate = self
        downloader.start()
        _started = true
    }
    
    public func stop() {
        if _started == false { return }
        
        downloader.stop()
        _started = false
    }
    
    public func setSelectedNetworkIDs(ids: [CBNetworkType]) {
        downloader.selectedNetworkIDs = ids
    }
    
    public func forceUpdate() {
        downloader.forceStationsUpdate()
    }
    
    /// MARK: - CBScheduledDownloaderDelegate
    func cbdownloaderDidDownloadNetworks(networks: [CBNetwork]?, error: NSError?) {
        if let error = error {
            postNotification(.DidUpdateNetworks, userInfo: ["error": error])
            
        } else {
            delegate?.updateNetworks(networks!) {
                self.postNotification(.DidUpdateNetworks, userInfo: nil)
            }
        }
    }
    
    func cbdownloaderDidDownloadNetworksWithStations(networksAndStations: [CBNetwork]?, error: NSError?) {
        if let error = error {
            postNotification(.DidUpdateStations, userInfo: ["error": error])
            
        } else {
            delegate?.updateNetworksWithStations(networksAndStations!) {
                self.postNotification(.DidUpdateStations, userInfo: nil)
            }
        }
    }
    
    private func postNotification(type: CBSyncManagerNotification, userInfo: Dictionary<String, AnyObject>?) {
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(type.rawValue, object: nil, userInfo: userInfo)
        }
    }
}