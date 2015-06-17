//
//  RideHistoryEntry.swift
//  
//
//  Created by Tomasz Szulc on 12/06/15.
//
//

import Foundation

@objc(CDRideHistoryEntry)
public class CDRideHistoryEntry: NSManagedObject {

    @NSManaged public var duration: NSNumber
    @NSManaged public var startTimeInterval: NSNumber
    @NSManaged public var day: CDRideHistoryDay
}
