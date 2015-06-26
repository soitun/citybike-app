//
//  StationOnMapContext.swift
//  CityBike
//
//  Created by Tomasz Szulc on 24/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreLocation

class StationOnMapContext {
    var proxy: WatchStationProxy
    var userLocation: CLLocation
    
    init(proxy: WatchStationProxy, userLocation: CLLocation) {
        self.proxy = proxy
        self.userLocation = userLocation
    }
}