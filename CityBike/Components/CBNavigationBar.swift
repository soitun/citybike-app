//
//  CBNavigationBar.swift
//  CityBike
//
//  Created by Tomasz Szulc on 10/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

/**!
This subclass is responsible for customizing navigation bar.
*/
class CBNavigationBar: UINavigationBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.topItem == nil { return }
        
        if let leftItems = self.topItem?.leftBarButtonItems as? [UIBarButtonItem] {
            for leftItem in leftItems {
                if let customView = leftItem.customView {
                    var frame = customView.frame
                    frame.size.width = 29.0
                    frame.size.height = 29.0
                    leftItem.customView!.frame = frame
                }
            }
        }
    }

}
