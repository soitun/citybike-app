//
//  StationTableRowController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import WatchKit
import Model

class StationTableRowController: NSObject {
    @IBOutlet weak var freeBikesCircleImage: WKInterfaceImage!
    @IBOutlet weak var freeBikesLabel: WKInterfaceLabel!
    
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stationNameLabel: WKInterfaceLabel!
    
    func configure(proxy: WatchStationProxy) {
        freeBikesLabel.setText("\(proxy.freeBikes)/\(proxy.allSlots)")
        freeBikesCircleImage.setTintColor(UIColor.colorForValue(proxy.freeBikes, min: 0, max: proxy.allSlots))
        stationNameLabel.setText(proxy.name)
    
        if let distance = proxy.distanceToUser {
            distanceLabel.setText(String(format: "%0.1fkm", distance / 1000.0))
            distanceLabel.setHidden(false)
        } else {
            distanceLabel.setHidden(true)
        }
    }
}