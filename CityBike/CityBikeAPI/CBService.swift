//
//  CBService.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class CBService {
    
    /// Base URL of the backend in current version
    static private let CBServiceBaseURL = "http://api.citybik.es/v2/networks/"
    
    
    /**
    Singleton of CBService
    */
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
    
    
    /**
    Get stations of specified network types.
    */
    func fetchStationsForNetworkTypes(types: [CBNetworkType], completion: (result: Dictionary<CBNetworkType, [CBStation]>, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            /// stations will be grouped by type and stored here.
            var results = Dictionary<CBNetworkType, [CBStation]>()
            
            var operationError: NSError?
            
            /// create semaphore to be able to control flow of the method
            var semaphore = dispatch_semaphore_create(0)
            
            /// create queue when all requests will be planned.
            var queue = NSOperationQueue()
            queue.maxConcurrentOperationCount = 1
            queue.suspended = true
            
            /// add block operation for every type
            for idx in 0..<types.count {
                let networkType = types[idx]
                
                queue.addOperation(NSBlockOperation(block: { () -> Void in
                    self.fetchNetworkForType(networkType, completion: { (network: CBNetwork?, error: NSError?) -> Void in
                        if let network = network {
                            results[network.networkType] = network.stations
                        }
                        
                        operationError = error
                        
                        /// unlock when last operation is finished
                        if idx == types.count - 1 {
                            dispatch_semaphore_signal(semaphore)
                        }
                    })
                }))
            }
            
            queue.suspended = false
            
            /// lock
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            completion(result: results, error: operationError)
        })
    }
    
    
    /**
    Get bike network object of specified type
    */
    func fetchNetworkForType(type: CBNetworkType!, completion: (network: CBNetwork?, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.makeRequest(type.rawValue, completion: { (response, error) -> Void in
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    let network = CBJSONParser.parseNetwork(jsonResult["network"] as! CBJSONParser.JSON)
                    completion(network: network, error: error)
                } else {
                    completion(network: nil, error: error)
                }
            })
        })
    }
    
    
    /**
    Get every network available on the server without stations data. Just networks infos.
    */
    func fetchNetworks(completion: (networks: [CBNetwork], error: NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.makeRequest(nil, completion: { (response, error) -> Void in
                if let jsonResult = response as? CBJSONParser.JSON {
                    var networks = [CBNetwork]()
                    for jsonNetwork in jsonResult["networks"] as! [CBJSONParser.JSON] {
                        networks.append(CBJSONParser.parseNetwork(jsonNetwork))
                    }
                    
                    completion(networks: networks, error: error)
                } else {
                    completion(networks: [CBNetwork](), error: error)
                }
            })
        })
    }
    
    
    
    /// MARK: - Private
    private func makeRequest(path: String?, completion: (response: AnyObject?, error:NSError?) -> Void) {
        let url: NSURL?
        let baseURL = NSURL(string: CBService.CBServiceBaseURL)
        
        if let path = path {
            url = NSURL(string: path, relativeToURL: baseURL)!
        } else {
            url = baseURL
        }
        
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if let data = data {
                var parseError: NSError? = nil
                if let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) {
                    completion(response: jsonResult, error: error)
                    
                } else if let parseError = parseError {
                    completion(response: nil, error: parseError)
                }
                
            } else if let error = error {
                completion(response: nil, error: error)
            }
        }
    }
}