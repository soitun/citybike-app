//
//  MapDetailView.swift
//  CityBike
//
//  Created by Tomasz Szulc on 19/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import Swifternalization

protocol CBMapDetailViewDelegate {
    func mapDetailViewDidPressClose(view: MapDetailView)
}

class MapDetailView: UIView {
    
    var delegate: CBMapDetailViewDelegate?
    
    @IBOutlet weak var labelTop: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var labelThird: UILabel!
    
    @IBOutlet private weak var bikesImageView: UIImageView!
    @IBOutlet private weak var bikesLabel: UILabel!

    @IBOutlet private weak var distanceContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private var previousDistance: Float = 0.0
    private var previousBikes = 0
    private var previousSlots = 0
    
    
    @IBAction func closePressed(sender: AnyObject) {
        delegate?.mapDetailViewDidPressClose(self)
    }
    
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        return super.CustomAwakeAfterUsingCoder(aDecoder, nibName: "MapDetailView")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        distanceContainer.makeRounded()
        distanceContainer.backgroundColor = UIColor.plentyColor()
        distanceContainer.layer.cornerRadius = (CGRectGetHeight(distanceContainer.frame) / CGFloat(2.0))
    }
    
    func update(text: String, detailText: String, freeBikes: Int, freeSlots: Int, distance: Float?, date: NSDate) {
        labelTop.text = text.uppercaseString
        labelDetails.text = detailText.uppercaseString
        
        let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)!.boolValue
        if let distance = distance {
            if fabs(distance - previousDistance) > 50.0 {
                previousDistance = distance
                
                if usesMetric == true {
                    distanceLabel.text = String(format: "%0.2fkm", DistanceConverter(distance).km)
                } else {
                    distanceLabel.text = String(format: "%0.2fmi", DistanceConverter(distance).mi)
                }
                
                distanceLabel.hidden = false
                distanceContainer.bounce(0.1)
            }
        } else {
            if usesMetric == true {
                distanceLabel.text = "- - km"
            } else {
                distanceLabel.text = "- - mi"
            }
        }
        
        
        if freeBikes != previousBikes {
            previousBikes = freeBikes
            bikesImageView.tintColor = UIColor.colorForValue(freeBikes, min: 0, max: freeBikes + freeSlots)
            bikesLabel.text = "\(freeBikes)/\(freeBikes + freeSlots)"
            bikesImageView.bounce(0.1)
        }
        
        labelThird.text = I18n.localizedString("updated") + " " + "\(date.updatedWhileAgoTextualRepresentation())"
    }
}