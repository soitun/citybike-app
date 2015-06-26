//
//  Stationable.swift
//  CityBike
//
//  Created by Tomasz Szulc on 25/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import Model

protocol Stationable: class {
    var station: Station {get set}
}