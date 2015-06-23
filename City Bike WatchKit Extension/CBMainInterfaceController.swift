//
//  CBMainInterfaceController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation


class CBMainInterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        configureUserSettings()
    }

    override func willActivate() {
        super.willActivate()
        WKInterfaceController.reloadRootControllersWithNames(["CBStationsListInterfaceController", "CBStopwatchInterfaceController"], contexts: nil)
    }
    
    private func configureUserSettings() {
        let defaults = NSUserDefaults(suiteName: CBConstant.AppSharedGroup.rawValue)!
        let userSettings = CBUserSettings(userDefaults: defaults)
        CBUserSettings.setSharedInstance(userSettings)
        
        /// Register defaults values
        CBUserSettings.sharedInstance().registerDefaults()
    }
}
