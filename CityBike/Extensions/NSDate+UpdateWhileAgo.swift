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
                return I18n.localizedString("now")
                
            } else {
                return String(format:I18n.localizedExpressionString("time-seconds", value: tc.seconds), tc.seconds)
            }
        } else if tc.hours == 0 {
            return String(format:I18n.localizedExpressionString("time-minutes", value: tc.minutes), tc.minutes)
        } else if tc.hours <= 2 {
            return String(format:I18n.localizedExpressionString("time-hours", value: tc.hours), tc.hours)
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            return dateFormatter.stringFromDate(self)
        }
    }
}