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
    
    func copy() -> CBNetwork {
        var obj = CBNetwork()
        obj.company = self.company
        obj.href = self.href
        obj.id = self.id
        obj.location = self.location.copy()
        obj.name = self.name
        
        var stations = [CBStation]()
        for station in self.stations {
            stations.append(station.copy())
        }
        obj.stations = stations
        return obj
    }
}