//
//  CBUpdateTableRowController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import WatchKit

class CBUpdateTableRowController: NSObject {
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var dateLabel: WKInterfaceLabel!

    func update(date: NSDate) {
        titleLabel.setText(NSLocalizedString("RECENTLY UPDATED", comment: ""))
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        dateLabel.setText(dateFormatter.stringFromDate(date))
    }
}