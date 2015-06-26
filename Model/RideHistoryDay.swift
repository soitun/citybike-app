//
//  RideHistoryDay.swift
//  
//
//  Created by Tomasz Szulc on 12/06/15.
//
//

import Foundation

@objc(RideHistoryDay)
public class RideHistoryDay: NSManagedObject {
    
    @NSManaged public var date: NSDate
    @NSManaged public var entries: NSOrderedSet
    
    public func addEntry(entry: RideHistoryEntry) {
        var mutableEntries = NSMutableOrderedSet(orderedSet: entries, copyItems: false)
        mutableEntries.addObject(entry)
        self.entries = NSOrderedSet(orderedSet: mutableEntries, copyItems: false)
    }
}
