//
//  CBFilterNetwork.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

struct CBFilteredNetworksGroupProxy {
    var countryCode: CountryCode
    var countryName: String
    var networks = [CBFilteredNetworkProxy]()
    
    init(code: CountryCode, country: String) {
        countryCode = code
        countryName = country
    }
}

struct CBFilteredNetworkProxy {
    var name: String
    var city: String
    var id: String
}

class CBFilterNetworks {
    
    class func filteredNetworks(networkGroups: [CBOrderedNetworksGroup], phrase: String) -> [CBFilteredNetworksGroupProxy] {
        func containsLowercase(str1: String, str2: String) -> Bool {
            return str1.lowercaseString.rangeOfString(str2) != nil
        }
        
        var searchPhrase = phrase.lowercaseString
        
        var result = [CBFilteredNetworksGroupProxy]()
        for group in networkGroups {
            if containsLowercase(group.countryCode, searchPhrase) || containsLowercase(group.countryName, searchPhrase) {
                var groupProxy = CBFilteredNetworksGroupProxy(code: group.countryCode, country: group.countryName)
                for network in group.networks {
                    groupProxy.networks.append(CBFilteredNetworkProxy(name: network.name, city: network.location.city, id: network.id))
                }
                
                result.append(groupProxy)
            } else {
                var filteredNetworks = [CBFilteredNetworkProxy]()
                for network in group.networks {
                    if containsLowercase(network.name, searchPhrase) || containsLowercase(network.location.city, searchPhrase) {
                        filteredNetworks.append(CBFilteredNetworkProxy(name: network.name, city: network.location.city, id: network.id))
                    }
                }
                
                if filteredNetworks.count > 0 {
                    var groupProxy = CBFilteredNetworksGroupProxy(code: group.countryCode, country: group.countryName)
                    groupProxy.networks = filteredNetworks
                    result.append(groupProxy)
                }
            }
        }
        
        return result
    }
}
