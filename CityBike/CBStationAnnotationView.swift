//
//  CBStationAnnotationView2.swift
//  CityBike
//
//  Created by Tomasz Szulc on 25/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit
import CBModel

class CBStationAnnotationView: MKAnnotationView, CBMapUpdaterProtocol {
    private var previousFreeBikes = 0
    
    @IBOutlet private var bikesCircle: UIImageView!
    @IBOutlet private var bikesLabel: UILabel!
    @IBOutlet private var customView: UIView!
    
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.configureUI()
    }
    
    private func configureUI() {
        let nib = UINib(nibName: "CBStationAnnotationView", bundle: NSBundle.mainBundle())
        nib.instantiateWithOwner(self, options: nil).first
        
        if self.customView != nil {
            self.addSubview(customView)
            self.customView.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        self.setTranslatesAutoresizingMaskIntoConstraints(false)

        /// Add constraints to make this view the same size as the custom one
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: customView, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: customView, attribute: .Height, multiplier: 1, constant: 0)
        self.addConstraints([widthConstraint, heightConstraint])
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    /// MARK: Logic
    func configure(station: CDStation) {
        var bikes = station.freeBikes.integerValue
        var slots = station.emptySlots.integerValue
        self.bikesCircle.tintColor = UIColor.colorForValue(bikes, min: 0, max: bikes + slots)
        
        self.bikesLabel.text = "\(bikes)/\(bikes + slots)"
        
        if self.previousFreeBikes != bikes {
            self.previousFreeBikes = bikes
            self.bikesCircle.bounce(0.1)
        }
    }
    
    
    /// MARK: CBMapUpdaterProtocol
    func update(station: CDStation) {
        self.configure(station)
    }
}