//
//  StationOnMapInterfaceController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 24/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class StationOnMapInterfaceController: WKInterfaceController {

    @IBOutlet private weak var map: WKInterfaceMap!
    
    private var context: StationOnMapContext!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.context = context as! StationOnMapContext
    }

    override func willActivate() {
        super.willActivate()
        
        map.addAnnotation(context.userLocation.coordinate, withPinColor: .Green)
        map.addAnnotation(context.proxy.coordinate, withPinColor: .Red)
        map.setRegion(MKCoordinateRegion.regionForCoordinates([context.userLocation.coordinate, context.proxy.coordinate]))
    }
}