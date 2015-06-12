//
//  CBStationAnnotationView.swift
//  CityBike
//
//  Created by Tomasz Szulc on 11/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit

class CBStationAnnotationView: MKAnnotationView {
    
    var plentyColor: UIColor!
    var fewColor: UIColor!
    var noneColor: UIColor!
    
    private var previousFreeBikes = 0
    private var previousEmptySlots = 0
    
    private var containerView: UIView!
    private var bikesCircle: UIImageView!
    private var bikesLabel: UILabel!
    private var slotsCircle: UIImageView!
    private var slotsLabel: UILabel!
    
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.configureUI()
    }
    
    private func configureUI() {
        self.containerView = UIView(frame: CGRectZero)
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(self.containerView)
        
        let heightConstraint = NSLayoutConstraint(item: self.containerView, attribute: .Height, relatedBy: .Equal, toItem:nil , attribute: .NotAnAttribute, multiplier: 1, constant: 29)
        let centerXConstraint = NSLayoutConstraint(item: self.containerView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: self.containerView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: -17)
        self.addConstraints([heightConstraint, centerXConstraint, centerYConstraint])
        
        self.configureBackground()
        self.configureCone()
        self.configBikesCircle()
        self.configBikesLabel()
        self.configSlotsCircle()
        self.configSlotsLabel()
    }
    
    private func configureBackground() {
        /// Add background view
        let backgroundImage = UIImage(named: "annotation-view-background")
        let resizableImage = backgroundImage?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 20, 0, 20))
        let backgroundView = UIImageView(frame: CGRectZero)
        backgroundView.image = resizableImage
        
        backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.addSubview(backgroundView)
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[backgroundView]-(0)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["backgroundView": backgroundView])
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[backgroundView]-(0)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["backgroundView": backgroundView])
        
        self.containerView.addConstraints(horizontalConstraints)
        self.containerView.addConstraints(verticalConstraints)
    }
    
    private func configureCone() {
        let coneView = UIImageView(image: UIImage(named: "annotation-view-cone"))
        coneView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addSubview(coneView)
        
        let centerXConstraint = NSLayoutConstraint(item: coneView, attribute: .CenterX, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterX, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: coneView, attribute: .Top, relatedBy: .Equal, toItem: self.containerView, attribute: .Bottom, multiplier: 1, constant: 0)
        self.addConstraints([centerXConstraint, topConstraint])
    }
    
    
    private func configBikesCircle() {
        self.bikesCircle = self.createCircleImageView()
        self.containerView.addSubview(self.bikesCircle)
        
        let widthConstraint = NSLayoutConstraint(item: self.bikesCircle, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.bikesCircle.image!.size.width)
        let leadingConstraint = NSLayoutConstraint(item: self.bikesCircle, attribute: .Leading, relatedBy: .Equal, toItem: self.containerView, attribute: .Leading, multiplier: 1, constant: 5)
        let centerYConstraint = NSLayoutConstraint(item: self.bikesCircle, attribute: .CenterY, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterY, multiplier: 1, constant: 0)
        self.containerView.addConstraints([widthConstraint, leadingConstraint, centerYConstraint])
    }
    
    private func configBikesLabel() {
        self.bikesLabel = self.createLabel()
        
        self.containerView.addSubview(self.bikesLabel)
        let leadingConstraint = NSLayoutConstraint(item: self.bikesLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.bikesCircle, attribute: .Trailing, multiplier: 1, constant: 2)
        let centerYConstraint = NSLayoutConstraint(item: self.bikesLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterY, multiplier: 1, constant: 0)
        self.containerView.addConstraints([leadingConstraint, centerYConstraint])
    }
    
    
    private func configSlotsCircle() {
        self.slotsCircle = self.createCircleImageView()
        self.containerView.addSubview(self.slotsCircle)
        
        let widthConstraint = NSLayoutConstraint(item: self.slotsCircle, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.slotsCircle.image!.size.width)
        let leadingConstraint = NSLayoutConstraint(item: self.slotsCircle, attribute: .Leading, relatedBy: .Equal, toItem: self.bikesLabel, attribute: .Trailing, multiplier: 1, constant: 5)
        let centerYConstraint = NSLayoutConstraint(item: self.slotsCircle, attribute: .CenterY, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterY, multiplier: 1, constant: 0)
        self.containerView.addConstraints([widthConstraint, leadingConstraint, centerYConstraint])
    }
    
    private func configSlotsLabel() {
        self.slotsLabel = self.createLabel()
        self.containerView.addSubview(self.slotsLabel)
        
        let leadingConstraint = NSLayoutConstraint(item: self.slotsLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.slotsCircle, attribute: .Trailing, multiplier: 1, constant: 2)
        let centerYConstraint = NSLayoutConstraint(item: self.slotsLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterY, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self.slotsLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.containerView, attribute: .Trailing, multiplier: 1, constant: -5)
        self.containerView.addConstraints([leadingConstraint, centerYConstraint, trailingConstraint])
    }
    
    
    private func createCircleImageView() -> UIImageView {
        let view = UIImageView(image: UIImage(named: "annotation-view-circle"))
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel(frame: CGRectZero)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.font = UIFont(name: "AvenirNextCondensed-Medium", size: 14.0)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Left
        label.text = "0"
        return label
    }
    

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    func configure(station: CBStation!) {
        /// Set free bikes color
        if station.freeBikes > 5 {
            self.bikesCircle.tintColor = self.plentyColor
            
        } else if station.freeBikes <= 5 && station.freeBikes > 0 {
            self.bikesCircle.tintColor = self.fewColor
            
        } else if station.freeBikes == 0 {
            self.bikesCircle.tintColor = self.noneColor
        }
        
        /// Set empty slots color
        if station.emptySlots > 5 {
            self.slotsCircle.tintColor = self.plentyColor
            
        } else if station.emptySlots <= 5 && station.emptySlots > 0 {
            self.slotsCircle.tintColor = self.fewColor
            
        } else if station.emptySlots == 0 {
            self.slotsCircle.tintColor = self.noneColor
        }
        
        self.bikesLabel.text = "\(station.freeBikes)"
        self.slotsLabel.text = "\(station.emptySlots)"
        
        if self.previousFreeBikes != station.freeBikes {
            self.previousFreeBikes = station.freeBikes
            self.animateView(self.bikesCircle)
        }
        
        if self.previousEmptySlots != station.emptySlots {
            self.previousEmptySlots = station.emptySlots
            self.animateView(self.slotsCircle)
        }
    }
    
    private func animateView(view: UIView) {
        view.alpha = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            view.alpha = 1
        })
    }
}