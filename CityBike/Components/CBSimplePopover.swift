//
//  CBSimplePopover.swift
//  CityBike
//
//  Created by Tomasz Szulc on 19/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBSimplePopover: UIView {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        return super.CustomAwakeAfterUsingCoder(aDecoder, nibName: "CBSimplePopover")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.makeRounded()
        self.label.textColor = UIColor.noneColor()
    }

}
