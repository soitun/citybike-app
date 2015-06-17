//
//  RideHistoryDay.swift
//  
//
//  Created by Tomasz Szulc on 12/06/15.
//
//

import Foundation

@objc(CDRideHistoryDay)
public class CDRideHistoryDay: NSManagedObject {
    
    /// time interval since 1970 when day started 00:00
    @NSManaged public var startTimeInterval: NSNumber
    @NSManaged public var entries: NSOrderedSet
    
    public func addEntry(entry: CDRideHistoryEntry) {
        var mutableEntries = NSMutableOrderedSet(orderedSet: entries, copyItems: false)
        mutableEntries.addObject(entry)
        self.entries = NSOrderedSet(orderedSet: mutableEntries, copyItems: false)
    }
}
