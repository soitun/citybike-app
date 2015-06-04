//
//  CBAnnotationView.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit

class CBAnnotationView: MKAnnotationView {
    
    var plentyColor: UIColor!
    var fewColor: UIColor!
    var noneColor: UIColor!

    @IBOutlet weak var leftValueBackground: UIImageView!
    @IBOutlet weak var rightValueBackground: UIImageView!
    @IBOutlet weak var leftValue: UILabel!
    @IBOutlet weak var rightValue: UILabel!
    
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        let loadedView = NSBundle.mainBundle().loadNibNamed("CBAnnotationView", owner: self, options: nil).first as! UIView
        self.addSubview(loadedView)
        
        loadedView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let centerX = NSLayoutConstraint(item: loadedView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: loadedView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        self.addConstraints([centerX, centerY])
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func configure(station: CBStation!) {
        self.leftValue.text = "\(station.freeBikes)"
        self.rightValue.text = "\(station.emptySlots)"
        
        /// Set free bikes color
        if station.freeBikes > 5 {
            self.leftValueBackground.tintColor = self.plentyColor
            
        } else if station.freeBikes <= 5 && station.freeBikes > 0 {
            self.leftValueBackground.tintColor = self.fewColor
            
        } else if station.freeBikes == 0 {
            self.leftValueBackground.tintColor = self.noneColor
        }
        
        /// Set empty slots color
        if station.emptySlots > 5 {
            self.rightValueBackground.tintColor = self.plentyColor
            
        } else if station.emptySlots <= 5 && station.emptySlots > 0 {
            self.rightValueBackground.tintColor = self.fewColor
            
        } else if station.emptySlots == 0 {
            self.rightValueBackground.tintColor = self.noneColor
        }
    }
}
