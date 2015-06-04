//
//  CBAnnotation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit

class CBAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?

    let station: CBStation!
    
    var coordinate: CLLocationCoordinate2D {
        return self.station.coordinate
    }

    init(station: CBStation!, title: String? = nil, subtitle: String? = nil) {
        self.station = station
        
        self.title = title
        self.subtitle = subtitle
    }
}