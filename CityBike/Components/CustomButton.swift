//
//  CustomButton.swift
//  CityBike
//
//  Created by Tomasz Szulc on 06/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    var normalBackgroundColor: UIColor!
    var pressedBackgroundColor: UIColor!

    override func awakeFromNib() {
        super.awakeFromNib()
        if self.normalBackgroundColor == nil {
            self.normalBackgroundColor = UIColor.whiteColor()
        }
        
        if self.pressedBackgroundColor == nil {
            self.normalBackgroundColor = UIColor.whiteColor()
        }
        
        self.makeNormalStyle()
    }
    
    func makeStyleEndGettingStarted() {
        self.makeRounded()
        self.normalBackgroundColor = UIColor(white: 1, alpha: 0.3)
        self.pressedBackgroundColor = UIColor(white: 1, alpha: 0.1)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.makeNormalStyle()
    }
    
    final override func sendAction(action: Selector, to target: AnyObject?, forEvent event: UIEvent?) {
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.15, animations: {
                self.makePressedStyle()
            }, completion: { _ in
                UIView.animateWithDuration(0.15, animations: {
                    self.makeNormalStyle()
                }, completion: { (finished) -> Void in
                    super.sendAction(action, to: target, forEvent: event)
                })
            })
        })
    }
    
    func makePressedStyle() {
        self.backgroundColor = self.pressedBackgroundColor
    }
    
    func makeNormalStyle() {
        self.backgroundColor = self.normalBackgroundColor
    }
}
