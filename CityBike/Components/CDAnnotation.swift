//
//  CDAnnotation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit

class CDAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    var station: CDStation
    
    var coordinate: CLLocationCoordinate2D {
        return self.station.coordinate
    }
    
    init(station: CDStation, title: String? = nil, subtitle: String? = nil) {
        self.station = station
        self.title = title
        self.subtitle = subtitle
    }
}