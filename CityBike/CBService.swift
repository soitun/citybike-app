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
    
    /// Get stations for passed network types
    func fetchStationsForNetworkTypes(types: [CBNetworkType], completion: (result: Dictionary<CBNetworkType, [CBStation]>) -> Void) {
        
        var result = Dictionary<CBNetworkType, [CBStation]>()
    
        var semaphore = dispatch_semaphore_create(0)
        
        var queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.suspended = true
        
        for idx in 0..<types.count {
            let networkType = types[idx]
            
            var operation = NSBlockOperation()
            var x = idx
            operation.addExecutionBlock({ () -> Void in
                self.fetchNetworkForType(networkType, completion: { (network: CBNetwork?) -> Void in
                    if let network = network {
                        result[network.networkType] = network.stations
                    }
                    
                    if x == types.count - 1 {
                        dispatch_semaphore_signal(semaphore)
                    }
                })
            })
            
            queue.addOperation(operation)
        }
        
        queue.suspended = false
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        completion(result: result)
    }
    
    /// Get latest info about specified network
    func fetchNetworkForType(type: CBNetworkType, completion: (network: CBNetwork?) -> Void) {
        self.makeRequest(type.rawValue, completion: { (response) -> Void in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                let network = CBJSONParser.parseNetwork(jsonResult["network"] as! CBJSONParser.JSON)
                completion(network: network)
            } else {
                completion(network: nil)
            }
        })
    }
    
    func fetchNetworks(completion: (networks: [CBNetwork]) -> Void) {
        self.makeRequest(nil, completion: { (response) -> Void in
            if let jsonResult = response as? CBJSONParser.JSON {
                var networks = [CBNetwork]()
                for jsonNetwork in jsonResult["networks"] as! [CBJSONParser.JSON] {
                    networks.append(CBJSONParser.parseNetwork(jsonNetwork))
                }
                
                completion(networks: networks)
            } else {
                completion(networks: [CBNetwork]())
            }
        })

    }
    
    private func makeRequest(path: String?, completion: (response: AnyObject?) -> Void) {
        let url: NSURL?
        let baseURL = NSURL(string: CBService.CBServiceBaseURL)
        
        if let path = path {
            url = NSURL(string: path, relativeToURL: baseURL)!
        } else {
            url = baseURL
        }
        
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var parseError: NSError? = nil
            let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError)
        
            if let jsonResult: AnyObject = jsonResult {
                completion(response: jsonResult)
                
            } else if let parseError = parseError {
                println(parseError)
                completion(response: nil)
            }
        }
    }
}