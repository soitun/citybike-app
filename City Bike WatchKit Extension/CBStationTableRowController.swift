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
    
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stationNameLabel: WKInterfaceLabel!
    
    func configure(proxy: CBWatchStationProxy) {
        freeBikesLabel.setText("\(proxy.freeBikes)/\(proxy.allSlots)")
        freeBikesCircleImage.setTintColor(colorForValue(proxy.freeBikes, min: 0, max: proxy.allSlots))
        stationNameLabel.setText(proxy.name)
    
        if let distance = proxy.distanceToUser {
            distanceLabel.setText(String(format: "%0.1fkm", distance / 1000.0))
            distanceLabel.setHidden(false)
        } else {
            distanceLabel.setHidden(true)
        }
    }
    
    private func colorForValue(value: Int, min: Int, max: Int) -> UIColor {
        var many = Float(max) * Float(0.30)
        var none = Float(max) * Float(0.15)
        
        if Float(value) > many { return UIColor.plentyColor() }
        else if Float(value) < none { return UIColor.noneColor() }
        else { return UIColor.fewColor() }
    }
}