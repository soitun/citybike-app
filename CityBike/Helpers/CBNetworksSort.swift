//
//  CBNetworksSort.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBOrderedNetworksGroup {
    var countryCode: String!
    var networks = [CDNetwork]()
    
    lazy var countryName: String! = {
        let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: self.countryCode])
        return NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: identifier)!
        }()
}

class CBNetworksSort {
    class func orderNetworks(var networks: [CDNetwork]) -> [CBOrderedNetworksGroup] {
        /// Store networks groupped by country code
        var orderedGroups = [CBOrderedNetworksGroup]()

        for network in networks {
            let key = network.location.country
            if let group = orderedGroups.filter({$0.countryCode == key}).first {
                group.networks.append(network)
            } else {
                var group = CBOrderedNetworksGroup()
                group.networks.append(network)
                group.countryCode = network.location.country
                orderedGroups.append(group)
            }
        }
        
        orderedGroups.sort({$0.countryName < $1.countryName})
        for group in orderedGroups {
            group.networks.sort({$0.name.lowercaseString < $1.name.lowercaseString})
        }

        return orderedGroups
    }
}