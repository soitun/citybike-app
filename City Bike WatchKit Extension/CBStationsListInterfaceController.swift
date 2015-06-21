//
//  InterfaceController.swift
//  City Bike WatchKit Extension
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation


class CBStationsListInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!

    private enum RowType: String {
        case Station = "CBStationTableRowController"
        case Update = "CBUpdateTableRowController"
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        loadTableData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func loadTableData() {
        
        let stations = 7
        let rows = stations + 1
        var rowTypes = [String]()
        for idx in 0..<rows {
            if idx < stations {
                rowTypes.append(RowType.Station.rawValue)
            } else {
                rowTypes.append(RowType.Update.rawValue)
            }
        }
        
        table.setRowTypes(rowTypes)
        
        for idx in 0..<rows {
            if idx < stations {
                let row = table.rowControllerAtIndex(idx) as! CBStationTableRowController
            } else {
                let row = table.rowControllerAtIndex(idx) as! CBUpdateTableRowController
            }
        }
        
    }
}