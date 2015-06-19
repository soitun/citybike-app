//
//  CBMapButton.swift
//  CityBike
//
//  Created by Tomasz Szulc on 19/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBMapButton: CBButton {

    final override func makePressedStyle() {
        self.alpha = 0.8
        self.bounce(0.1)
    }
    
    final override func makeNormalStyle() {
        self.alpha = 1
    }
}
