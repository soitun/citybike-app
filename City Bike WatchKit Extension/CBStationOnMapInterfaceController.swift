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

class CBStationOnMapContext {
    var proxy: CBWatchStationProxy
    var userLocation: CLLocation
    
    init(proxy: CBWatchStationProxy, userLocation: CLLocation) {
        self.proxy = proxy
        self.userLocation = userLocation
    }
}

class CBStationOnMapInterfaceController: WKInterfaceController {

    @IBOutlet private weak var map: WKInterfaceMap!
    private var context: CBStationOnMapContext!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.context = context as! CBStationOnMapContext
    }

    override func willActivate() {
        super.willActivate()
        
        self.setTitle(NSLocalizedString("Close", comment: ""))
        
        map.addAnnotation(context.userLocation.coordinate, withPinColor: .Green)
        map.addAnnotation(context.proxy.coordinate, withPinColor: .Red)
        map.setRegion(MKCoordinateRegion.regionForCoordinates([context.userLocation.coordinate, context.proxy.coordinate]))
    }
}

extension MKCoordinateRegion {
    static func regionForCoordinates(coordinates: Array<CLLocationCoordinate2D>) -> MKCoordinateRegion {
        var minLat = 90.0
        var maxLat = -90.0
        var minLon = 180.0
        var maxLon = -180.0
        
        for coordinate in coordinates {
            if coordinate.latitude < minLat { minLat = coordinate.latitude }
            if coordinate.longitude < minLon { minLon = coordinate.longitude }
            if coordinate.latitude > maxLat { maxLat = coordinate.latitude }
            if coordinate.longitude > maxLon { maxLon = coordinate.longitude }
        }
        
        let offset = 0.5
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * (1 + offset), longitudeDelta: (maxLon - minLon) * (1 + offset))
        let center = CLLocationCoordinate2D(latitude: maxLat - (span.latitudeDelta * (1 - offset)) / 2.0, longitude: maxLon - (span.longitudeDelta * (1 - offset)) / 2.0)
        return MKCoordinateRegionMake(center, span)
    }
}