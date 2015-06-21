//
//  AppDelegate.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CBModel
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    private var locationManager = CLLocationManager()
    private var requestingData = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        configureCoreData()
        startRequestingData()
        
        updateUI()
        showProperViewController()
        
        return true
    }
    
    private func configureCoreData() {
        let cdModel = CoreDataModel(name: "CityBike", bundle:NSBundle(forClass: CoreDataStack.self))
        let cdStack = CoreDataStack(model: cdModel, storeType: NSSQLiteStoreType, concurrencyType: .MainQueueConcurrencyType)
        CoreDataStack.setSharedInstance(cdStack)
    }
    
    private func showProperViewController() {
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var rootVC: UIViewController!
        if CBUserDefaults.sharedInstance.getDisplayedGettingStarted() {
            rootVC = storyboard.instantiateViewControllerWithIdentifier("CBMapViewController") as! CBMapViewController
        } else {
            rootVC = storyboard.instantiateViewControllerWithIdentifier("CBGettingStartedViewController") as! UIViewController
        }
        
        self.window!.rootViewController = rootVC
        self.window!.makeKeyAndVisible()
    }
    
    private func updateUI() {
        UINavigationBar.appearance().tintColor = UIColor.flamePeaColor()
        
        var fontAttributes = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17.0)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = fontAttributes
    }
    
    func startRequestingData() {
        if requestingData == true { return }
        requestingData = true
        
        // Register defaults
        CBUserDefaults.sharedInstance.registerCityBikeDefaults()

        // Request location updates
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = 30.0
        
        // Request content
        CBModelUpdater.sharedInstance.start()
    }
    
    /// MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            println("ios-app: location update")
            CBWormhole.sharedInstance.passMessageObject(location, identifier: CBWormholeNotification.UserLocationUpdate.rawValue)
        }
    }
    
    
    /// MARK: Apple Watch
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        if let rawRequest = userInfo?["request"] as? String {
            if let event = CBAppleWatchEvent(rawValue: rawRequest) {
                switch event {
                    case .RequestUpdates: startRequestingData()
                }
            }
        }
        
    }
}

