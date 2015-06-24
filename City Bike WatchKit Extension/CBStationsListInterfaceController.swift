//
//  InterfaceController.swift
//  City Bike WatchKit Extension
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation
import CBModel
import CoreLocation

class CBStationsListInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    
    private var userLocation: CLLocation?
    private var requesterTimer: NSTimer?
    
    private var wasReloadedWithoutContent = false
    private var locServices = CBLocationServicesFlags()

    private enum RowType: String {
        case Station = "CBStationTableRowController"
        case Update = "CBUpdateTableRowController"
        case Warning = "CBWarningTableRowController"
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        WKInterfaceController.openParentApplication(["request": CBAppleWatchEvent.InitialConfiguration.rawValue], reply: { (dict, error) -> Void in
            println("W: Initial Configuration")
        })
        
        self.observeWormholeNotifications()
        reloadContent()
        scheduleFetchRequest()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        requesterTimer?.invalidate()
    }
    
    private func scheduleFetchRequest() {
        requesterTimer?.invalidate()
        requesterTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("fetchRequestFired"), userInfo: nil, repeats: true)
        fetchRequestFired()
    }
    
    @objc private func fetchRequestFired() {
        WKInterfaceController.openParentApplication(["request": CBAppleWatchEvent.FetchData.rawValue], reply: { (dict, error) -> Void in
            println("W: Fetch Data")
            println(dict)

            if let dict = dict as? [String: AnyObject] {
                var latitude: CLLocationDegrees? = dict["latitude"] as? CLLocationDegrees
                var longitude: CLLocationDegrees? = dict["longitude"] as? CLLocationDegrees
                if latitude != nil && longitude != nil {
                    self.userLocation = CLLocation(latitude: latitude!, longitude: longitude!)
                }
            } else {
                self.userLocation = nil
            }
            
            self.reloadContent()
        })
    }
    
    /// MARK: Notifications
    private func observeWormholeNotifications() {
        CBWormhole.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.ContentUpdate.rawValue, listener: { _ in
            println("W: Content Update")
            self.reloadContent()
        })
        
        CBWormhole.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.UserLocationUpdate.rawValue, listener: { (updatedLocation: AnyObject?) in
            println("W: Location Update")
            self.userLocation = updatedLocation as? CLLocation
            self.reloadContent()
        })
    }

    private func reloadContent() {
        locServices.refreshFlags()
        
        if locServices.isWorking == false {
            self.userLocation = nil
        }
        
        var stations: [CDStation] = CDStationManager.allStationsForSelectedNetworks()
        if stations.count == 0 {
            /// Do not refresh if nothing changed
            if (locServices.enabledChanged == false && locServices.enabled == false &&
                locServices.accessGrantedChanged == false && locServices.accessGranted == false &&
                wasReloadedWithoutContent == true) { return }
            
            wasReloadedWithoutContent = true
            reloadTableWithNoStations()
        } else if stations.count > 0 {
            wasReloadedWithoutContent = false
            reloadTableWithStations(stations)
        }
    }
    
    private func reloadTableWithNoStations() {
        typealias RowIndex = Int
        var rowTypes = [String]()
        var warningTypes = [CBWarningType]()
        
        // No stations cell
        rowTypes.append(RowType.Warning.rawValue)
        warningTypes.append(.NoStations)
        
        // Should add any warning cell?
        if locServices.enabled == false {
            self.userLocation = nil
            warningTypes.append(.LocationServicesDisabled)
            rowTypes.append(RowType.Warning.rawValue)
            
        } else if locServices.accessGranted == false {
            self.userLocation = nil
            warningTypes.append(.LocationServicesAccessDenied)
            rowTypes.append(RowType.Warning.rawValue)
        }
        
        table.setRowTypes(rowTypes)
        
        var idx: RowIndex = 0
        for rowType in rowTypes {
            let row = table.rowControllerAtIndex(idx) as! CBWarningTableRowController
            row.configure(warningTypes[idx])
            idx++
        }
    }
    
    private func reloadTableWithStations(stations: [CDStation]) {
        var proxies = createStationProxiesFromStations(stations)
        sortProxies(&proxies)
        
        // Add rows for proxies
        var rowTypes = [String]()
        for idx in 0..<proxies.count {
            rowTypes.append(RowType.Station.rawValue)
        }
        
        /// Add row for "Recently Updated"
        rowTypes.append(RowType.Update.rawValue)
        
        // Should add any warning cell?
        var warningTypes = [CBWarningType]()
        if locServices.enabled == false {
            warningTypes.append(.LocationServicesDisabled)
            rowTypes.append(RowType.Warning.rawValue)
            
        } else if locServices.accessGranted == false {
            warningTypes.append(.LocationServicesAccessDenied)
            rowTypes.append(RowType.Warning.rawValue)
        }
        
        table.setRowTypes(rowTypes)

        var recentTimestamp = NSDate(timeIntervalSince1970: 0)
        
        var rowIdx = 0
        var warningIdx = 0
        for rowType in rowTypes {
            if rowType == RowType.Station.rawValue {
                let row = table.rowControllerAtIndex(rowIdx) as! CBStationTableRowController
                let proxy = proxies[rowIdx]
                row.configure(proxy)
                
                /// check recent timestamp
                if recentTimestamp.laterDate(proxy.updateTimestamp) == proxy.updateTimestamp {
                    recentTimestamp = proxy.updateTimestamp
                }
                
            } else if rowType == RowType.Update.rawValue {
                let row = table.rowControllerAtIndex(rowIdx) as! CBUpdateTableRowController
                row.configure(recentTimestamp)
                
            } else if rowType == RowType.Warning.rawValue {
                let row = table.rowControllerAtIndex(rowIdx) as! CBWarningTableRowController
                row.configure(warningTypes[warningIdx])
                warningIdx++
            }
            
            rowIdx++
        }
    }
    
    private func createStationProxiesFromStations(stations: [CDStation]) -> [CBWatchStationProxy] {
        var stationProxies = [CBWatchStationProxy]()
        
        for station in stations {
            var proxy = CBWatchStationProxy(station: station)
            stationProxies.append(proxy)
            
            if let userLocation = userLocation {
                let stationLocation = CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude)
                proxy.distanceToUser = userLocation.distanceFromLocation(stationLocation)
            } else {
                proxy.distanceToUser = nil
            }
        }
        
        return stationProxies
    }
    
    /// sort by free bikes descending or by distance if location available
    private func sortProxies(inout proxies: [CBWatchStationProxy]) {
        proxies.sort({
            if ($0.distanceToUser == nil || $1.distanceToUser == nil) { return $0.freeBikes > $1.freeBikes }
            if $0.distanceToUser! == $1.distanceToUser! { return $0.freeBikes > $1.freeBikes }
            else { return $0.distanceToUser! < $1.distanceToUser! }
        })
    }
}
