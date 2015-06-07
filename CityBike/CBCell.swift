//
//  CBCell.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBCell: UITableViewCell {

    override var layoutMargins: UIEdgeInsets {
        set {
            super.layoutMargins = newValue
        }
        
        get {
            return UIEdgeInsetsZero
        }
    }
}
