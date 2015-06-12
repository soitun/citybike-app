//
//  RideHistoryDay.swift
//  
//
//  Created by Tomasz Szulc on 12/06/15.
//
//

import Foundation
import CoreData

class RideHistoryDay: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var entries: NSOrderedSet

}
