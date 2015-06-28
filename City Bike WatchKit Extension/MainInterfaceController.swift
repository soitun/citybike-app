//
//  MainInterfaceController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class MainInterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        I18N(bundle: NSBundle(forClass: StationManager.self))
        configureUserSettings()
        configureCoreData()
    }

    override func willActivate() {
        super.willActivate()
        WKInterfaceController.reloadRootControllersWithNames(["StationsListInterfaceController", "StopwatchInterfaceController"], contexts: nil)
    }
    
    private func configureCoreData() {
        let cdModel = CoreDataModel(name: "CityBike", bundle:NSBundle(forClass: CoreDataStack.self), sharedGroup: Constant.AppSharedGroup.rawValue)
        let cdStack = CoreDataStack(model: cdModel, storeType: NSSQLiteStoreType, concurrencyType: .MainQueueConcurrencyType)
        CoreDataStack.setSharedInstance(cdStack)
    }
    
    private func configureUserSettings() {
        let defaults = NSUserDefaults(suiteName: Constant.AppSharedGroup.rawValue)!
        let userSettings = UserSettings(userDefaults: defaults)
        UserSettings.setSharedInstance(userSettings)
        
        /// Register defaults values
        UserSettings.sharedInstance().registerDefaults()
    }
}
