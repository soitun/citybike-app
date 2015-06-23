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
    private var wasReloadedWithoutContent = false

    private enum RowType: String {
        case Station = "CBStationTableRowController"
        case Update = "CBUpdateTableRowController"
        case Warning = "CBWarningTableRowController"
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        WKInterfaceController.openParentApplication(["request": CBAppleWatchEvent.RequestUpdates.rawValue], reply: nil)
    }

    override func willActivate() {
        super.willActivate()
        self.observeWormholeNotifications()
        reloadTable()
    }
    
    /// MARK: Notifications
    private func observeWormholeNotifications() {
        CBWormhole.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.ContentUpdate.rawValue, listener: { _ in
            println("watch: content update")
            self.reloadTable()
        })
        
        CBWormhole.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.UserLocationUpdate.rawValue, listener: { (updatedLocation: AnyObject?) in
            println("watch: location update")
            self.userLocation = updatedLocation as? CLLocation
            self.reloadTable()
        })
    }

    private func reloadTable() {
        var stations: [CDStation] = CDStationManager.allStationsForSelectedNetworks()
        if stations.count == 0 && wasReloadedWithoutContent == false {
            wasReloadedWithoutContent = true
            reloadWithNoStations()
        } else if stations.count > 0 {
            wasReloadedWithoutContent = false
            reloadWithStations(stations)
        }
    }
    
    private func reloadWithNoStations() {
        typealias RowIndex = Int
        var rowTypes = [String]()
        var warningTypes = [CBWarningType]()
        
        // No stations cell
        rowTypes.append(RowType.Warning.rawValue)
        warningTypes.append(.NoStations)
        
        // Should add any warning cell?
        if showLocationServicesDisabledRow() {
            warningTypes.append(.LocationServicesDisabled)
            rowTypes.append(RowType.Warning.rawValue)
        } else if showLocationServicesAccessDenied() {
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
    
    private func reloadWithStations(stations: [CDStation]) {
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
        if showLocationServicesDisabledRow() {
            warningTypes.append(.LocationServicesDisabled)
            rowTypes.append(RowType.Warning.rawValue)
        } else if showLocationServicesAccessDenied() {
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
            }
        }
        
        return stationProxies
    }
    
    private func sortProxies(inout proxies: [CBWatchStationProxy]) {
        /// sort by free bikes descending or by distance if location available
        proxies.sort({
            if $0.distanceToUser != nil && $1.distanceToUser != nil {
                if $0.distanceToUser! == $1.distanceToUser! { return $0.freeBikes > $1.freeBikes }
                else { return $0.distanceToUser! < $1.distanceToUser! }
            }
            
            return $0.freeBikes > $1.freeBikes
        })
    }
    
    private func showLocationServicesDisabledRow() -> Bool {
        return CLLocationManager.locationServicesEnabled() == false
    }
    
    private func showLocationServicesAccessDenied() -> Bool {
        let authStatus = CLLocationManager.authorizationStatus()
        return (authStatus != .AuthorizedAlways && authStatus != .AuthorizedWhenInUse)
    }
}