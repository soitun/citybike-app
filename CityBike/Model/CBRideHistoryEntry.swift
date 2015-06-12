//
//  RideHistoryEntry.swift
//  
//
//  Created by Tomasz Szulc on 12/06/15.
//
//

import Foundation
import CoreData

@objc(CBRideHistoryEntry)
class CBRideHistoryEntry: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var startTimeInterval: NSNumber
    @NSManaged var day: CBRideHistoryDay

}
