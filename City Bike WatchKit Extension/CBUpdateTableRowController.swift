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

    func configure(date: NSDate) {
        titleLabel.setText(NSLocalizedString("RECENTLY UPDATED", comment: ""))
        
        let timeIntervalSinceNow = abs(date.timeIntervalSinceNow)
        let tc = timeIntervalSinceNow.timeComponents()
        
        if tc.hours == 0 && tc.minutes == 0 {
            if tc.seconds == 0 {
                dateLabel.setText(NSLocalizedString("Now", comment: ""))
            } else {
                let text = String.localizedStringWithFormat("%d seconds ago", tc.seconds)
                dateLabel.setText(text)
            }
        } else if tc.hours == 0 {
            let text = String.localizedStringWithFormat("%d minutes ago", tc.minutes)
            dateLabel.setText(text)
        } else if tc.hours <= 2 {
            let text = String.localizedStringWithFormat("%d hours ago", tc.hours)
            dateLabel.setText(text)
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            dateLabel.setText(dateFormatter.stringFromDate(date))
        }
    }
}