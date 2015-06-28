//
//  InterfaceController.swift
//  City Bike WatchKit Extension
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation
import Model
import CoreLocation

private enum RowType: String {
    case Station = "StationTableRowController"
    case Update = "UpdateTableRowController"
    case Warning = "MessageTableRowController"
}

class StationsListInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    private var proxies = [WatchStationProxy]()
    private var userLocation: CLLocation?
    private var displayedFetchingData = false
    
    private var displayedWarning: MessageType?
    
    // MARK: Life-cycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.setTitle(I18n.localizedString("bikes"))
    }

    override func willActivate() {
        super.willActivate()
        WKInterfaceController.openParentApplication(["request": AppleWatchEvent.InitialConfiguration.rawValue], reply: { (dict, error) -> Void in
            println("Initial iOS App Configuration")
        })
        
        if displayedFetchingData == false {
            displayedFetchingData = true
            reloadWithWarning(.FetchingData)
        }
        
        fetchData()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

    
    // MARK: Private methods
    private func fetchData() {
        WKInterfaceController.openParentApplication(["request": AppleWatchEvent.FetchData.rawValue], reply: { (dict, error) -> Void in
//            println("Fetched Data")
            println(dict)
            
            if let dict = dict as? [String: AnyObject] {
                var latitude = dict["latitude"] as? CLLocationDegrees
                var longitude = dict["longitude"] as? CLLocationDegrees
                if latitude != nil && longitude != nil {
                    self.userLocation = CLLocation(latitude: latitude!, longitude: longitude!)
                }
            }
            
            if self.userLocation == nil {
                self.reloadContent(nil)
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.fetchData()
                }
                
            } else {
                self.reloadContent(self.userLocation)
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
            var stations = StationManager.allStationsForSelectedNetworks(resetContext: true) as [Station]
            if stations.count == 0 {
                reloadWithWarning(.NoStations)
                
            } else if stations.count > 0 {
                self.displayedWarning = nil
                reloadTableWithStations(stations, userLocation: userLocation!)
            }
        }
    }
    
    private func reloadWithWarning(warning: MessageType) {
        if let messageType = self.displayedWarning where messageType == warning {
            return
        }
        
        self.displayedWarning = warning
        table.setRowTypes([RowType.Warning.rawValue])
        var row = table.rowControllerAtIndex(0) as! MessageTableRowController
        row.configure(warning)
    }

    private func reloadTableWithStations(stations: [Station], userLocation: CLLocation) {
        proxies = createStationProxiesFromStations(stations, userLocation: userLocation)
        sortProxies(&proxies)
        
        if proxies.count > 5 {
            var slice = proxies[0..<5] as ArraySlice<WatchStationProxy>
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
                let row = table.rowControllerAtIndex(rowIdx) as! StationTableRowController
                let proxy = proxies[rowIdx]
                row.configure(proxy)
                
                /// check recent timestamp
                if recentTimestamp.laterDate(proxy.updateTimestamp) == proxy.updateTimestamp {
                    recentTimestamp = proxy.updateTimestamp
                }
                
            } else if rowType == RowType.Update.rawValue {
                let row = table.rowControllerAtIndex(rowIdx) as! UpdateTableRowController
                row.configure(recentTimestamp)
            }
            
            rowIdx++
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let row: AnyObject? = table.rowControllerAtIndex(rowIndex)
        if row is StationTableRowController {
            let proxy = proxies[rowIndex]
            
            var context = StationOnMapContext(proxy: proxy, userLocation: userLocation!)
            self.presentControllerWithName("StationOnMapInterfaceController", context: context)
            
        } else if row is UpdateTableRowController {
            fetchData()
        }
    }
    
    private func createStationProxiesFromStations(stations: [Station], userLocation: CLLocation) -> [WatchStationProxy] {
        var stationProxies = [WatchStationProxy]()
        
        for station in stations {
            var proxy = WatchStationProxy(station: station)
            stationProxies.append(proxy)
            
            let stationLocation = CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude)
            proxy.distanceToUser = userLocation.distanceFromLocation(stationLocation)
        }
        
        return stationProxies
    }
    
    private func sortProxies(inout proxies: [WatchStationProxy]) {
        /// sort by free bikes descending or by distance if location available
        proxies.sort({
            if ($0.distanceToUser == nil || $1.distanceToUser == nil) { return $0.freeBikes > $1.freeBikes }
            if $0.distanceToUser! == $1.distanceToUser! { return $0.freeBikes > $1.freeBikes }
            else { return $0.distanceToUser! < $1.distanceToUser! }
        })
    }
}
