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
    
    /// Get latest info about specified network
    func fetchNetwork(type: CBNetworkType, completion: (network: CBNetwork?) -> Void) {
        let baseURL = NSURL(string: CBService.CBServiceBaseURL)
        let url = NSURL(string: type.rawValue, relativeToURL: baseURL)!
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            println(response)
            
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