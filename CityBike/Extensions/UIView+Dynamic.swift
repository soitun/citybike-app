//
//  UIView+Dynamic.swift
//  CityBike
//
//  Created by Tomasz Szulc on 20/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

extension UIView {
    
    func changeVisibility(show: Bool, animated: Bool) {
        let duration = animated ? 0.25 : 0
        if show == true && self.hidden == true {
            self.alpha = 0
            self.hidden = false
            UIView.animateWithDuration(duration, animations: { self.alpha = 1 })
            
        } else if show == false && self.hidden == false {
            self.alpha = 1
            UIView.animateWithDuration(duration, animations: { self.alpha = 0 }) { _ in self.hidden = true }
        }
    }
    
    func bounce(duration: NSTimeInterval) {
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
}