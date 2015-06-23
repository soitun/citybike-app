//
//  CBStationTableRowController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import WatchKit
import CBModel

class CBStationTableRowController: NSObject {
    @IBOutlet weak var freeBikesCircleImage: WKInterfaceImage!
    @IBOutlet weak var freeBikesLabel: WKInterfaceLabel!
    
    @IBOutlet weak var freeSlotsCircleImage: WKInterfaceImage!
    @IBOutlet weak var freeSlotsLabel: WKInterfaceLabel!
    
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stationNameLabel: WKInterfaceLabel!
    
    func configure(proxy: CBWatchStationProxy) {
        freeBikesLabel.setText("\(proxy.freeBikes)")
        freeBikesCircleImage.setTintColor(colorForValue(proxy.freeBikes, min: 0, max: 5))
        
        freeSlotsLabel.setText("\(proxy.emptySlots)")
        freeSlotsCircleImage.setTintColor(colorForValue(proxy.emptySlots, min: 0, max: 5))
        stationNameLabel.setText(proxy.name)
    
        if let distance = proxy.distanceToUser {
            distanceLabel.setText(String(format: "%0.1fkm", distance / 1000.0))
            distanceLabel.setHidden(false)
        } else {
            distanceLabel.setHidden(true)
        }
    }
    
    private func colorForValue(value: Int, min: Int, max: Int) -> UIColor {
        if value > max { return UIColor.plentyColor() }
        else if value == 0 { return UIColor.noneColor() }
        else { return UIColor.fewColor() }
    }
}