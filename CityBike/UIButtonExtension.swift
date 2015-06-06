//
//  UIButtonExtension.swift
//  CityBike
//
//  Created by Tomasz Szulc on 06/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

extension UIButton {
    func makeStyleReddish() {
        self.makeRounded()
        self.backgroundColor = UIColor.flamePeaColor()
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func makeStyleShadowedWhite() {
        self.makeRounded()
        self.makeShadowed()
        self.backgroundColor = UIColor.whiteColor()
        self.setTitleColor(UIColor.blueGrayColor(), forState: UIControlState.Normal)
    }
}