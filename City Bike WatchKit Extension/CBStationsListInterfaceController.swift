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

class CBStationsListInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!

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
        
        let stations: [CDStation] = CDStation.fetchAll(CoreDataStack.sharedInstance().mainContext) as! [CDStation]
        loadTableData(stations)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func loadTableData(stations: [CDStation]) {
        if stations.count > 0 {
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
                    row.update(stations[idx])
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