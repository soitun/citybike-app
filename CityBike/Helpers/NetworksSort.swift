//
//  NetworksSort.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CBModel

class OrderedNetworksGroup {
    var countryCode: CountryCode
    var networks: [CDNetwork]
    
    init(countryCode: String, networks: [CDNetwork]) {
        self.countryCode = countryCode
        self.networks = networks
    }
    
    lazy var countryName: String! = {
        let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: self.countryCode])
        return NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: identifier)!
        }()
}

class NetworksSort {
    class func orderNetworks(networks: [CDNetwork]) -> [OrderedNetworksGroup] {
        /// Store networks groupped by country code
        var orderedGroups = [OrderedNetworksGroup]()
        
        for network in networks {
            let ccKey = network.location.country
            if let group = orderedGroups.filter({$0.countryCode == ccKey}).first {
                group.networks.append(network)
                
            } else {
                orderedGroups.append(OrderedNetworksGroup(countryCode: network.location.country, networks: [network]))
            }
        }
        
        orderedGroups.sort({$0.countryName < $1.countryName})
        for group in orderedGroups {
            group.networks.sort({$0.name.lowercaseString < $1.name.lowercaseString})
        }

        return orderedGroups
    }
}