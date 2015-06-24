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

private enum RowType: String {
    case Station = "CBStationTableRowController"
    case Update = "CBUpdateTableRowController"
    case Warning = "CBWarningTableRowController"
}

class CBStationsListInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    
    
    // MARK: Life-cycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        WKInterfaceController.openParentApplication(["request": CBAppleWatchEvent.InitialConfiguration.rawValue], reply: { (dict, error) -> Void in
            println("Initial iOS App Configuration")
        })
        
        fetchData()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

    
    // MARK: Private methods
    private func fetchData() {
        WKInterfaceController.openParentApplication(["request": CBAppleWatchEvent.FetchData.rawValue], reply: { (dict, error) -> Void in
            println("Fetched Data")
            println(dict)
            
            var userLocation: CLLocation?
            
            if let dict = dict as? [String: AnyObject] {
                var latitude = dict["latitude"] as? CLLocationDegrees
                var longitude = dict["longitude"] as? CLLocationDegrees
                if latitude != nil && longitude != nil {
                    userLocation = CLLocation(latitude: latitude!, longitude: longitude!)
                }
            }
            
            if userLocation == nil {
                self.reloadContent(nil)
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.fetchData()
                }
                
            } else {
                self.reloadContent(userLocation)
            }
        })
    }
    
    private func isLocationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled() == true
    }
    
    private func isLocationServicesAccessGranted() -> Bool {
        let authStatus = CLLocationManager.authorizationStatus()
        return (authStatus == .AuthorizedAlways || authStatus == .AuthorizedWhenInUse)
    }


    private func reloadContent(userLocation: CLLocation?) {
        if isLocationServicesEnabled() == false || isLocationServicesAccessGranted() == false {
            reloadWithWarning(.LocationServicesDisabled)
            
        } else if userLocation == nil {
            reloadWithWarning(.CannotObtainUserLocation)

        } else {
            var stations = CDStationManager.allStationsForSelectedNetworks() as [CDStation]
            if stations.count == 0 {
                reloadWithWarning(.NoStations)
                
            } else if stations.count > 0 {
                reloadTableWithStations(stations, userLocation: userLocation!)
            }
        }
    }
    
    private func reloadWithWarning(warning: CBWarningType) {
        table.setNumberOfRows(1, withRowType: RowType.Warning.rawValue)
        var row = table.rowControllerAtIndex(0) as! CBWarningTableRowController
        row.configure(warning)
    }

    private func reloadTableWithStations(stations: [CDStation], userLocation: CLLocation) {
        var proxies = createStationProxiesFromStations(stations, userLocation: userLocation)
        sortProxies(&proxies)
        
        if proxies.count > 5 {
            var slice = proxies[0..<5] as ArraySlice<CBWatchStationProxy>
            proxies = Array(slice)
        }
        
        // Add rows for proxies
        var rowTypes = [String]()
        for idx in 0..<proxies.count {
            rowTypes.append(RowType.Station.rawValue)
        }
        
        /// Add row for "Recently Updated"
        rowTypes.append(RowType.Update.rawValue)
        table.setRowTypes(rowTypes)

        var recentTimestamp = NSDate(timeIntervalSince1970: 0)
        var rowIdx = 0
        
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
            }
            
            rowIdx++
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let row: AnyObject? = table.rowControllerAtIndex(rowIndex)
        if row is CBUpdateTableRowController {
            fetchData()
        }
    }
    
    private func createStationProxiesFromStations(stations: [CDStation], userLocation: CLLocation) -> [CBWatchStationProxy] {
        var stationProxies = [CBWatchStationProxy]()
        
        for station in stations {
            var proxy = CBWatchStationProxy(station: station)
            stationProxies.append(proxy)
            
            let stationLocation = CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude)
            proxy.distanceToUser = userLocation.distanceFromLocation(stationLocation)
        }
        
        return stationProxies
    }
    
    private func sortProxies(inout proxies: [CBWatchStationProxy]) {
        /// sort by free bikes descending or by distance if location available
        proxies.sort({
            if ($0.distanceToUser == nil || $1.distanceToUser == nil) { return $0.freeBikes > $1.freeBikes }
            if $0.distanceToUser! == $1.distanceToUser! { return $0.freeBikes > $1.freeBikes }
            else { return $0.distanceToUser! < $1.distanceToUser! }
        })
    }
}
