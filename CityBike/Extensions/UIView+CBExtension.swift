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
}

extension UIView {
    
    public func CustomAwakeAfterUsingCoder(aDecoder: NSCoder, nibName: String) -> AnyObject? {
        if (self.subviews.count == 0) {
            let nib = UINib(nibName: nibName, bundle: nil)
            let loadedView = nib.instantiateWithOwner(nil, options: nil).first as! UIView
            
            /// set view as placeholder is set
            loadedView.frame = self.frame
            loadedView.autoresizingMask = self.autoresizingMask
            loadedView.setTranslatesAutoresizingMaskIntoConstraints(self.translatesAutoresizingMaskIntoConstraints())
            
            for constraint in self.constraints() as! [NSLayoutConstraint] {
                var firstItem = constraint.firstItem as! UIView
                if firstItem == self {
                    firstItem = loadedView
                }
                
                var secondItem = constraint.secondItem as! UIView?
                if secondItem != nil {
                    if secondItem! == self {
                        secondItem = loadedView
                    }
                }
                
                loadedView.addConstraint(NSLayoutConstraint(item: firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
            }
            
            return loadedView
        }
        
        return self
    }
}