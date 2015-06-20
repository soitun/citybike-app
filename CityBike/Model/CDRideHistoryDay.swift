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
    
    @NSManaged public var date: NSDate
    @NSManaged public var entries: NSOrderedSet
    
    public func addEntry(entry: CDRideHistoryEntry) {
        var mutableEntries = NSMutableOrderedSet(orderedSet: entries, copyItems: false)
        mutableEntries.addObject(entry)
        self.entries = NSOrderedSet(orderedSet: mutableEntries, copyItems: false)
    }
}
