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
import Swifternalization

class StationOnMapInterfaceController: WKInterfaceController {

    @IBOutlet private weak var map: WKInterfaceMap!
    @IBOutlet var messageTable: WKInterfaceTable!
    @IBOutlet var tryAgainButton: WKInterfaceButton!
    @IBOutlet var messageGroup: WKInterfaceGroup!
    
    private var context: StationOnMapContext!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.context = context as! StationOnMapContext        
    }

    override func willActivate() {
        super.willActivate()
        updateUI()
    }
    
    private func updateUI() {
        let hasConnectivity = CBReachability.hasConnectivity()
        map.setHidden(!hasConnectivity)
        messageGroup.setHidden(hasConnectivity)
        
        if hasConnectivity {
            map.addAnnotation(context.userLocation.coordinate, withImageNamed: "user-pin", centerOffset: CGPointZero)
            map.addAnnotation(context.proxy.coordinate, withPinColor: WKInterfaceMapPinColor.Green)
            map.setRegion(MKCoordinateRegion.regionForCoordinates([context.userLocation.coordinate, context.proxy.coordinate]))
        } else {
            messageTable.setRowTypes(["MessageTableRowController"])
            var row = messageTable.rowControllerAtIndex(0) as! MessageTableRowController
            row.configure(MessageType.NoInternet)
        }
    }
    
    @IBAction func tryAgainPressed() {
        updateUI()
    }
}