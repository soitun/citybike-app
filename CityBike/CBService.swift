//
//  CBService.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBService {
    
    static private let CBServiceBaseURL = "http://api.citybik.es/v2/networks/"
    
    /// Get shared instance
    class var sharedInstance: CBService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: CBService? = nil
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            Static.instance = CBService()
        })
        
        return Static.instance!
    }
    
    func fetchNetworks(completion: (networks: [CBNetwork]) -> Void) {
        let baseURL = NSURL(string: CBService.CBServiceBaseURL)
        let request = NSURLRequest(URL: baseURL!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var parseError: NSError? = nil
            let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError)
            
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                var networks = [CBNetwork]()
                for jsonNetwork in jsonResult["networks"] as! [CBJSONParser.JSON] {
                    networks.append(CBJSONParser.parseNetwork(jsonNetwork))
                }
                
                completion(networks: networks)
            
            } else {
                println(parseError)
                completion(networks: [])
            }
        }
    }
    
    /// Get stations for passed network types
    func fetchStationsForNetworkTypes(types: [CBNetworkType], completion: (stations: [CBStation]) -> Void) {
        
    }
    
    /// Get latest info about specified network
    func fetchNetworkForType(type: CBNetworkType, completion: (network: CBNetwork?) -> Void) {
        let baseURL = NSURL(string: CBService.CBServiceBaseURL)
        let url = NSURL(string: type.rawValue, relativeToURL: baseURL)!
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var parseError: NSError? = nil
            let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError)
            
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                let network = CBJSONParser.parseNetwork(jsonResult["network"] as! CBJSONParser.JSON)
                completion(network: network)
                
            } else {
                println(parseError)
                completion(network: nil)
            }
        }
    }
}