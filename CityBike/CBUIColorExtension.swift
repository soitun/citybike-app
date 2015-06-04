//
//  CBUIColorExtension.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

extension UIColor {
    class func noneColor() -> UIColor {
        return UIColor(red:1, green:0.42, blue:0.49, alpha:1)
    }
    
    class func fewColor() -> UIColor {
        return UIColor(red:1, green:0.94, blue:0.23, alpha:1)
    }
    
    class func plentyColor() -> UIColor {
        return UIColor(red:0.6, green:0.92, blue:0.24, alpha:1)
    }
}