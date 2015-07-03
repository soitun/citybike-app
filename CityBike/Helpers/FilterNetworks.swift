//
//  CBFilterNetwork.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CityBikesAPI

struct FilteredNetworksGroupProxy {
    var countryCode: CountryCode
    var countryName: String
    var networks = [FilteredNetworkProxy]()
    
    init(code: CountryCode, country: String) {
        countryCode = code
        countryName = country
    }
}

struct FilteredNetworkProxy {
    var name: String
    var city: String
    var id: String
}

class FilterNetworks {
    
    class func filteredNetworks(networkGroups: [OrderedNetworksGroup], phrase: String) -> [FilteredNetworksGroupProxy] {
        func containsLowercase(str1: String, str2: String) -> Bool {
            return str1.lowercaseString.rangeOfString(str2) != nil
        }
        
        var searchPhrase = phrase.lowercaseString
        
        var result = [FilteredNetworksGroupProxy]()
        for group in networkGroups {
            if containsLowercase(group.countryCode, searchPhrase) || containsLowercase(group.countryName, searchPhrase) {
                var groupProxy = FilteredNetworksGroupProxy(code: group.countryCode, country: group.countryName)
                for network in group.networks {
                    groupProxy.networks.append(FilteredNetworkProxy(name: network.name, city: network.location.city, id: network.id))
                }
                
                result.append(groupProxy)
            } else {
                var filteredNetworks = [FilteredNetworkProxy]()
                for network in group.networks {
                    if containsLowercase(network.name, searchPhrase) || containsLowercase(network.location.city, searchPhrase) {
                        filteredNetworks.append(FilteredNetworkProxy(name: network.name, city: network.location.city, id: network.id))
                    }
                }
                
                if filteredNetworks.count > 0 {
                    var groupProxy = FilteredNetworksGroupProxy(code: group.countryCode, country: group.countryName)
                    groupProxy.networks = filteredNetworks
                    result.append(groupProxy)
                }
            }
        }
        
        return result
    }
}
