//
//  RideHistoryDay.swift
//  
//
//  Created by Tomasz Szulc on 12/06/15.
//
//

import Foundation
import CoreData

@objc(CDRideHistoryDay)
class CDRideHistoryDay: NSManagedObject {
    
    /// time interval since 1970 when day started 00:00
    @NSManaged var startTimeInterval: NSNumber
    @NSManaged var entries: NSOrderedSet
    
    private class func entityName() -> String {
        return "CDRideHistoryDay"
    }
    
    class func allDays() -> [CDRideHistoryDay] {
        let fetchRequest = NSFetchRequest(entityName: self.entityName())
        if let days = CoreDataHelper.mainContext.executeFetchRequest(fetchRequest, error: nil) {
            return days as! [CDRideHistoryDay]
        } else {
            return [CDRideHistoryDay]()
        }
    }
    
    class func findDayForStartTimeInterval(ti: NSTimeInterval) -> CDRideHistoryDay? {
        let fetchRequest = NSFetchRequest(entityName: self.entityName())
        fetchRequest.predicate = NSPredicate(format: "startTimeInterval == %@", NSNumber(double: ti))
        return CoreDataHelper.mainContext.executeFetchRequest(fetchRequest, error: nil)?.first as? CDRideHistoryDay
    }
    
    func addEntry(entry: CDRideHistoryEntry) {
        var mutableEntries = NSMutableOrderedSet(orderedSet: entries, copyItems: false)
        mutableEntries.addObject(entry)
        self.entries = NSOrderedSet(orderedSet: mutableEntries, copyItems: false)
    }
}
