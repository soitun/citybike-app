//
//  UIColor+AnnotationCircle.swift
//  CityBike
//
//  Created by Tomasz Szulc on 25/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorForValue(value: Int, min: Int, max: Int) -> UIColor {
        var many = Float(max) * Float(0.30)
        var none = Float(max) * Float(0.15)
        
        if Float(value) > many { return UIColor.plentyColor() }
        else if Float(value) < none { return UIColor.noneColor() }
        else { return UIColor.fewColor() }
    }
}