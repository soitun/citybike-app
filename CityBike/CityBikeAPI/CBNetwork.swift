//
//  CBNetwork.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBNetwork: NSObject, NSCopying {
    var company: String!
    var href: String!
    var id: String!
    var location: CBLocation!
    var name: String!
    var stations: [CBStation]! = [CBStation]()
    
    var networkType: CBNetworkType {
        return CBNetworkType(rawValue: id)!
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        var copy = CBNetwork()
        copy.company = self.company
        copy.href = self.href
        copy.id = self.id
        copy.name = self.name
        copy.location = self.location.copy() as! CBLocation
        copy.stations = self.stations
        return copy
    }
}