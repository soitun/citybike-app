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
    
    private var refreshContentTimer: NSTimer?
    private var userLocation: CLLocation?

    private enum RowType: String {
        case Station = "CBStationTableRowController"
        case Update = "CBUpdateTableRowController"
        case NoStations = "CBNoStationsTableRowController"
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        self.startRefreshContentTimer()
        reloadTable()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func reloadTable() {
        var stations: [CDStation] = CDStation.fetchAll(CoreDataStack.sharedInstance().mainContext) as! [CDStation]
        
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
    
    private func startRefreshContentTimer() {
        self.refreshContentTimer?.invalidate()
        self.refreshContentTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("refreshContent"), userInfo: nil, repeats: true)
        self.refreshContent()
    }
    
    @objc private func refreshContent() {
        println("update")
        self.userLocation = CBUserDefaults.sharedInstance.getUserLocation()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.reloadTable()
        })
    }
}