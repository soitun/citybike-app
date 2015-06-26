//
//  MainInterfaceController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation


class MainInterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        configureUserSettings()
    }

    override func willActivate() {
        super.willActivate()
        WKInterfaceController.reloadRootControllersWithNames(["StationsListInterfaceController", "StopwatchInterfaceController"], contexts: nil)
    }
    
    private func configureUserSettings() {
        let defaults = NSUserDefaults(suiteName: Constant.AppSharedGroup.rawValue)!
        let userSettings = UserSettings(userDefaults: defaults)
        UserSettings.setSharedInstance(userSettings)
        
        /// Register defaults values
        UserSettings.sharedInstance().registerDefaults()
    }
}
