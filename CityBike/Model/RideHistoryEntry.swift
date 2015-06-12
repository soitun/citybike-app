//
//  RideHistoryEntry.swift
//  
//
//  Created by Tomasz Szulc on 12/06/15.
//
//

import Foundation
import CoreData

class RideHistoryEntry: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var startTime: NSData
    @NSManaged var day: RideHistoryDay

}
