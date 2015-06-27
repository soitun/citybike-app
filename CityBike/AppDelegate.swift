//
//  AppDelegate.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import Model
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    private var locationManager = CLLocationManager()
    private var configured = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        configureApp()
        
        startUpdatingLocation()
        
        updateUI()
        showProperViewController()
        return true
    }
    
    
    // MARK: Configuration
    private func configureApp() {
        if configured == false {
            configured = true
            configureUserSettings()
            configureCoreData()
            configureWormhole()
            startUpdatingLocation()
        }
    }
    
    private func configureUserSettings() {
        let defaults = NSUserDefaults(suiteName: Constant.AppSharedGroup.rawValue)!
        let userSettings = UserSettings(userDefaults: defaults)
        UserSettings.setSharedInstance(userSettings)
        
        /// Register defaults values
        UserSettings.sharedInstance().registerDefaults()
    }
    
    private func configureWormhole() {
        WormholeNotificationSystem.sharedInstance
    }
    
    private func configureCoreData() {
        let cdModel = CoreDataModel(name: "CityBike", bundle:NSBundle(forClass: CoreDataStack.self), sharedGroup: Constant.AppSharedGroup.rawValue)
        let cdStack = CoreDataStack(model: cdModel, storeType: NSSQLiteStoreType, concurrencyType: .MainQueueConcurrencyType)
        CoreDataStack.setSharedInstance(cdStack)
    }
    
    private func startUpdatingLocation() {
        // Request location updates
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = 30.0
    }
    
    // MARK: Other
    private func showProperViewController() {
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var rootVC: UIViewController!
        if UserSettings.sharedInstance().getDisplayedGettingStarted() {
            rootVC = storyboard.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        } else {
            rootVC = storyboard.instantiateViewControllerWithIdentifier("GettingStartedViewController") as! UIViewController
        }
        
        self.window!.rootViewController = rootVC
        self.window!.makeKeyAndVisible()
    }
    
    private func updateUI() {
        UINavigationBar.appearance().tintColor = UIColor.havelockBlue()
        
        var fontAttributes = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17.0)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = fontAttributes
    }
    
    /// MARK: Apple Watch
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        if let rawRequest = userInfo?["request"] as? String {
            if let event = AppleWatchEvent(rawValue: rawRequest) {
                switch event {
                case .InitialConfiguration:
                    configureApp()
                    // Request data only if calling from the watch
                    ModelUpdater.sharedInstance.start()
                    reply(nil)
                    
                case .FetchData:
                    if let location = self.locationManager.location {
                        reply(["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude])
                    } else {
                        reply(["user-location": "not available"])
                    }
                }
            }
        }
        
    }
}

