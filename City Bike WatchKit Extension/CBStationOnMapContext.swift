//
//  CBStationOnMapContext.swift
//  CityBike
//
//  Created by Tomasz Szulc on 24/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

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