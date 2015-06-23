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

    private enum RowType: String {
        case Station = "CBStationTableRowController"
        case Update = "CBUpdateTableRowController"
        case NoStations = "CBNoStationsTableRowController"
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
        
        /// sort by free bikes descending
        stations.sort({
            let bikes1 = $0.freeBikes.integerValue
            let bikes2 = $1.freeBikes.integerValue

            if let userLocation = self.userLocation {
                let location1 = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                let location2 = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
                
                let distance1 = self.userLocation!.distanceFromLocation(location1)
                let distance2 = self.userLocation!.distanceFromLocation(location2)
                
                if distance1 == distance2 {
                    return bikes1 > bikes2
                } else {
                    return distance1 < distance2
                }
            }

            return bikes1 > bikes2
            })
        
        if stations.count > 0  {
            let rows = stations.count + 1
            var rowTypes = [String]()
            for idx in 0..<rows {
                if idx < stations.count {
                    rowTypes.append(RowType.Station.rawValue)
                } else {
                    rowTypes.append(RowType.Update.rawValue)
                }
            }
            
            table.setRowTypes(rowTypes)
            
            for idx in 0..<rows {
                if idx < stations.count {
                    let row = table.rowControllerAtIndex(idx) as! CBStationTableRowController
                    let station = stations[idx]
                    var distance: Float?
                    if let userLocation = self.userLocation {
                        let stationLocation = CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude)
                        let distanceInMeters: Double = stationLocation.distanceFromLocation(userLocation)
                        let distanceInKm = distanceInMeters / 1000.0
                        distance = Float(distanceInKm)
                    }
                    
                    row.update(station, distance: distance)
                } else {
                    // Get recently update date
                    var recentTimestamp = NSDate(timeIntervalSince1970: 0)
                    for station in stations {
                        if recentTimestamp.laterDate(station.timestamp) == station.timestamp {
                            recentTimestamp = station.timestamp
                        }
                    }
                    
                    let row = table.rowControllerAtIndex(idx) as! CBUpdateTableRowController
                    row.update(recentTimestamp)
                }
            }
            
        } else {
            table.setNumberOfRows(1, withRowType: RowType.NoStations.rawValue)
            let row = table.rowControllerAtIndex(0) as! CBNoStationsTableRowController
            row.update()
        }
    }
}