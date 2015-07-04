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
    
        let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)!.boolValue
        if let distance = proxy.distanceToUser {
            if usesMetric == true {
                distanceLabel.setText(String(format: "%0.2fkm", DistanceConverter(distance).km))
            } else {
                distanceLabel.setText(String(format: "%0.2fmi", DistanceConverter(distance).mi))
            }
        } else {
            if usesMetric == true {
                distanceLabel.setText("- - km")
            } else {
                distanceLabel.setText("- - mi")
            }
        }
    }
}