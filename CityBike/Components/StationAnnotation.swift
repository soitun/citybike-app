//
//  StationAnnotation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit
import Model

class StationAnnotation: NSObject, Stationable, MKAnnotation {
    var station: Station
    var coordinate: CLLocationCoordinate2D { return station.coordinate }

    init(station: Station) {
        self.title = nil
        self.subtitle = nil
        
        self.station = station
    }
    
    
    
    /// Hide these properties, I don't need them.
    private let title: String?
    private let subtitle: String?
}