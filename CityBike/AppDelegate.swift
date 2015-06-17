//
//  AppDelegate.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CBModel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        NSUserDefaults.registerCityBikeDefaults()
        
        let cdModel = CoreDataModel(name: "CityBike", bundle:NSBundle(forClass: CoreDataHelper.self))
        let cdStack = CoreDataHelper(model: cdModel, storeType: NSSQLiteStoreType, concurrencyType: .MainQueueConcurrencyType)
        CoreDataHelper.setSharedInstance(cdStack)
        
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var rootVC: UIViewController!
        if NSUserDefaults.getDisplayedGettingStarted() {
            rootVC = storyboard.instantiateViewControllerWithIdentifier("CBMapViewControllerNC") as! UINavigationController
        } else {
            rootVC = storyboard.instantiateViewControllerWithIdentifier("CBGettingStartedViewController") as! UIViewController
        }
        
        self.window!.rootViewController = rootVC
        self.window!.makeKeyAndVisible()
        
        
        /// Update UI Style
        UINavigationBar.appearance().tintColor = UIColor.flamePeaColor()
        
        var fontAttributes = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17.0)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = fontAttributes

        
        return true
    }
}

