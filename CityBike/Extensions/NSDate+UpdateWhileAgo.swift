//
//  NSTimeInterval+UpdateWhileAgo.swift
//  CityBike
//
//  Created by Tomasz Szulc on 25/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

extension NSDate {
    
    func updatedWhileAgoTextualRepresentation() -> String {
        let tiSinceNow = abs(self.timeIntervalSinceNow)
        let tc = tiSinceNow.timeComponents()
        
        if tc.hours == 0 && tc.minutes == 0 {
            if tc.seconds < 30 {
                return NSLocalizedString("now", comment: "")
            } else {
                return String.localizedStringWithFormat("%d seconds ago", tc.seconds)
            }
        } else if tc.hours == 0 {
            let minuteText = (tc.minutes == 1) ? "minute" : "minutes"
            return String.localizedStringWithFormat("%d %@ ago", tc.minutes, minuteText)
        } else if tc.hours <= 2 {
            let hourText = (tc.hours == 1) ? "hour" : "hours"
            return String.localizedStringWithFormat("%d %@ ago", tc.hours, hourText)
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            return dateFormatter.stringFromDate(self)
        }
    }
}