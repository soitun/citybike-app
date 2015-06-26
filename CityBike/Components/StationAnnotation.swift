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

class StationAnnotation: NSObject, MKAnnotation {

    var stationProxy: StationProxy
    var coordinate: CLLocationCoordinate2D { return stationProxy.coordinate }

    init(stationProxy: StationProxy) {
        self.title = nil
        self.subtitle = nil
        
        self.stationProxy = stationProxy
    }
    
    
    /// Hide these properties, I don't need them.
    private let title: String?
    private let subtitle: String?
}