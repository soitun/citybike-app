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

class CBStationsListInterfaceController: WKInterfaceController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var table: WKInterfaceTable!
    
    private var fetchedRequestController: NSFetchedResultsController?

    private enum RowType: String {
        case Station = "CBStationTableRowController"
        case Update = "CBUpdateTableRowController"
        case NoStations = "CBNoStationsTableRowController"
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.configureFetchedResultsController()
    }

    override func willActivate() {
        super.willActivate()
        fetchedRequestController?.performFetch(nil)
        reloadTable()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func reloadTable() {
        let stations: [CDStation]? = self.fetchedRequestController?.fetchedObjects as? [CDStation]
        
        if stations != nil && stations?.count > 0  {
            let rows = stations!.count + 1
            var rowTypes = [String]()
            for idx in 0..<rows {
                if idx < stations!.count {
                    rowTypes.append(RowType.Station.rawValue)
                } else {
                    rowTypes.append(RowType.Update.rawValue)
                }
            }
            
            table.setRowTypes(rowTypes)
            
            for idx in 0..<rows {
                if idx < stations!.count {
                    let row = table.rowControllerAtIndex(idx) as! CBStationTableRowController
                    row.update(stations![idx])
                } else {
                    // Get recently update date
                    var recentTimestamp = NSDate(timeIntervalSince1970: 0)
                    for station in stations! {
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
    
    private func configureFetchedResultsController() {
        var request = CDStation.fetchAllRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedRequestController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.sharedInstance().mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedRequestController!.delegate = self
    }
    
    
    /// MARK: NSFetchedRequestControllerDelegate
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        dispatch_async(dispatch_get_main_queue()) { self.reloadTable() }
    }

}