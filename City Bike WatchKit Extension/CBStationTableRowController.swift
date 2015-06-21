//
//  CBStationTableRowController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import WatchKit

class CBStationTableRowController: NSObject {
    @IBOutlet weak var freeBikesCircleImage: WKInterfaceImage!
    @IBOutlet weak var freeBikesLabel: WKInterfaceLabel!
    
    @IBOutlet weak var freeSlotsCircleImage: WKInterfaceImage!
    @IBOutlet weak var freeSlotsLabel: WKInterfaceLabel!
    
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stationNameLabel: WKInterfaceLabel!
}