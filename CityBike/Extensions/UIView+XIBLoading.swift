//
//  UIView+XIBLoading.swift
//  CityBike
//
//  Created by Tomasz Szulc on 20/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

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