//
//  UIViewExtension.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

extension UIView {

    func makeShadowed() {
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 0.3
    }

    func makeRounded() {
        self.layer.cornerRadius = 6
    }
}