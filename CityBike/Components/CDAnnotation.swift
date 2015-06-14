//
//  CBAnnotation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit

class CBAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    var stationProxy: CBStationProxy
    
    var coordinate: CLLocationCoordinate2D {
        return self.stationProxy.coordinate
    }
    
    init(stationProxy: CBStationProxy, title: String? = nil, subtitle: String? = nil) {
        self.stationProxy = stationProxy
        self.title = title
        self.subtitle = subtitle
    }
}