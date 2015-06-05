//
//  CBNetwork.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBNetwork {
    var company: String!
    var href: String!
    var id: String!
    var location: CBLocation!
    var name: String!
    var stations: [CBStation]! = [CBStation]()
    
    var networkType: CBNetworkType {
        return CBNetworkType(rawValue: id)!
    }
}