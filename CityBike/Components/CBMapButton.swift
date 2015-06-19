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
        self.bounce()
    }
    
    private func bounce() {
        let duration = 0.1
        
        UIView.animateWithDuration(duration, animations: {
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2)
            
            }) { _ in
                UIView.animateWithDuration(duration, animations: {
                    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)
                    
                    }) { _ in
                        UIView.animateWithDuration(duration, animations: { _ in self.transform = CGAffineTransformIdentity })
                }
        }
    }
    
    final override func makeNormalStyle() {
        self.alpha = 1
    }
}
