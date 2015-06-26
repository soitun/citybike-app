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

class StationAnnotationView: ObservingAnnotationView {

    @IBOutlet private var bikesCircle: UIImageView!
    @IBOutlet private var bikesLabel: UILabel!
    @IBOutlet private var customView: UIView!

    private var previousFreeBikes = 0

    
    override init(annotation: Stationable, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configureUI()
        configure(annotation.station)
    }
    
    func configure(station: CDStation) {
        var bikes = station.freeBikes.integerValue
        var slots = station.emptySlots.integerValue
        bikesCircle.tintColor = UIColor.colorForValue(bikes, min: 0, max: bikes + slots)
        
        bikesLabel.text = "\(bikes)/\(bikes + slots)"
        
        if previousFreeBikes != bikes {
            previousFreeBikes = bikes
            bikesCircle.bounce(0.1)
        }
    }
    
    override func notificationReceived(notification: NSNotification) {
        theAnnotation.station = CDStation.fetchWithAttribute("id", value: theAnnotation.station.id, context: CoreDataStack.sharedInstance().mainContext).first as! CDStation
        configure(theAnnotation.station)
    }

    // MARK: Private
    private func configureUI() {
        let nib = UINib(nibName: "StationAnnotationView", bundle: NSBundle.mainBundle())
        nib.instantiateWithOwner(self, options: nil).first
        
        if customView != nil {
            addSubview(customView)
            customView.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        setTranslatesAutoresizingMaskIntoConstraints(false)

        /// Add constraints to make this view the same size as the custom one
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: customView, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: customView, attribute: .Height, multiplier: 1, constant: 0)
        addConstraints([widthConstraint, heightConstraint])
    }
   
    
    // MARK: Not to be used
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}