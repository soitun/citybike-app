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
import Swifternalization

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var configured = false
    private var taskIdentifier: UIBackgroundTaskIdentifier?
    private var replyBlock: (([NSObject : AnyObject]!) -> Void)!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        configureApp()
        startModelUpdater()
        updateUI()
        showProperViewController()
        return true
    }
    
    func startModelUpdater() {
        if ModelUpdater.sharedInstance.started == false {
            ModelUpdater.sharedInstance.setSelectedNetworkIds(UserSettings.sharedInstance().getNetworkIDs())
            ModelUpdater.sharedInstance.start()
        }
    }
    
    // MARK: Configuration
    private func configureApp() {
        if configured == false {
            configured = true
            I18n(bundle: NSBundle.mainBundle())
            configureUserSettings()
            configureCoreData()
            configureWormhole()
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
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "modelUpdaterDidFinishUpdate", name: ModelUpdater.Notification.UpdatedNetworksWithStations.rawValue, object: nil)
                    
                    configureApp()
                    // Request data only if calling from the watch
                    ModelUpdater.sharedInstance.start()
                    reply(nil)
                
                case .FetchData:
                    if taskIdentifier != nil {
                        reply([:])
                        return
                    }
                    
                    taskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                        if self.taskIdentifier != nil {
                            UIApplication.sharedApplication().endBackgroundTask(self.taskIdentifier!)
                        }
                    })
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        self.startModelUpdater()
                        self.replyBlock = reply
                    }
                    ModelUpdater.sharedInstance.forceUpdate()
                }
            }
        }
    }
    
    
    func modelUpdaterDidFinishUpdate() {
        if self.taskIdentifier == nil { return }
        
        self.replyBlock([:])
        ModelUpdater.sharedInstance.stop()
        UIApplication.sharedApplication().endBackgroundTask(self.taskIdentifier!)
        self.taskIdentifier = UIBackgroundTaskInvalid
        self.taskIdentifier = nil
    }
}

