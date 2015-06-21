//
//  CBNoStationsTableRowController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import WatchKit

class CBNoStationsTableRowController: NSObject {
    
    @IBOutlet weak var icon: WKInterfaceImage!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var detailTextLabel: WKInterfaceLabel!
    
    func update() {
        icon.setTintColor(UIColor.noneColor())
        titleLabel.setText(NSLocalizedString("No stations", comment: ""))
        detailTextLabel.setText(NSLocalizedString("Go to your iPhone and select some city bike network first.", comment: ""))
    }
}