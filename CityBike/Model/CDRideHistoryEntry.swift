//
//  RideHistoryEntry.swift
//  
//
//  Created by Tomasz Szulc on 12/06/15.
//
//

import Foundation
import CoreData

@objc(CDRideHistoryEntry)
class CDRideHistoryEntry: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var startTimeInterval: NSNumber
    @NSManaged var day: CDRideHistoryDay

}
