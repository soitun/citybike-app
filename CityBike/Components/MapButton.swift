//
//  MapButton.swift
//  CityBike
//
//  Created by Tomasz Szulc on 19/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class MapButton: CustomButton {

    final override func makePressedStyle() {
        alpha = 0.8
        bounce(0.1)
    }
    
    final override func makeNormalStyle() {
        alpha = 1
    }
}
