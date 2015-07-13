//
//  CBNetwork.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

public typealias CBNetworkType = String

public class CBNetwork {
    public var company: String!
    public var href: String!
    public var id: String!
    public var location: CBLocation!
    public var name: String!
    public var stations: [CBStation]! = [CBStation]()
    
    public var networkType: CBNetworkType { return id }
}