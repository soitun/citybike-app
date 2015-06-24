//
//  CBStationOnMapInterfaceController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 24/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class CBStationOnMapInterfaceController: WKInterfaceController {

    @IBOutlet private weak var map: WKInterfaceMap!
    
    private var context: CBStationOnMapContext!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.context = context as! CBStationOnMapContext
    }

    override func willActivate() {
        super.willActivate()
        
        map.addAnnotation(context.userLocation.coordinate, withPinColor: .Green)
        map.addAnnotation(context.proxy.coordinate, withPinColor: .Red)
        map.setRegion(MKCoordinateRegion.regionForCoordinates([context.userLocation.coordinate, context.proxy.coordinate]))
    }
}