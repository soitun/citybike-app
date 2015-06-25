//
//  StationManager.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CBModel

class StationManager {
    
    class func allStationsForSelectedNetworks() -> [CDStation] {
        let networkIDs = UserSettings.sharedInstance().getNetworkIDs()
        
        var stations = [CDStation]()
        for networkID in networkIDs {
            stations += CDStation.fetchWithAttribute("network.id", value: networkID, context: CoreDataStack.sharedInstance().mainContext) as! [CDStation]
        }
        
        return stations
    }
}