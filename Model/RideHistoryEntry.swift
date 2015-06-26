//
//  RideHistoryEntry.swift
//  
//
//  Created by Tomasz Szulc on 12/06/15.
//
//

import Foundation

@objc(RideHistoryEntry)
public class RideHistoryEntry: NSManagedObject {

    @NSManaged public var duration: NSNumber
    @NSManaged public var date: NSDate
    @NSManaged public var day: RideHistoryDay
}
