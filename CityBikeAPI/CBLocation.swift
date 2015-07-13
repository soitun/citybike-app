//
//  CBLocation.swift
//  CityBike
//
//  Created by Tomasz Szulc on 05/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreLocation

public typealias CountryCode = String

public class CBLocation {
    public var city: String
    public var country: CountryCode
    public var coordinate: CLLocationCoordinate2D
    
    public init(city: String, country: CountryCode, coordinate: CLLocationCoordinate2D) {
        self.city = city
        self.country = country
        self.coordinate = coordinate
    }
}