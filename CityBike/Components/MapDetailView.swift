//
//  MapDetailView.swift
//  CityBike
//
//  Created by Tomasz Szulc on 19/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

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
        self.delegate?.mapDetailViewDidPressClose(self)
    }
    
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        return super.CustomAwakeAfterUsingCoder(aDecoder, nibName: "MapDetailView")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.distanceContainer.makeRounded()
        self.distanceContainer.backgroundColor = UIColor.plentyColor()
        self.distanceContainer.layer.cornerRadius = (CGRectGetHeight(self.distanceContainer.frame) / CGFloat(2.0))
    }
    
    func update(text: String, detailText: String, freeBikes: Int, freeSlots: Int, distance: Float, date: NSDate) {
        self.labelTop.text = text.uppercaseString
        self.labelDetails.text = detailText.uppercaseString
        
        let newDistance = distance / 1000.0
        if fabs(newDistance - previousDistance) > 0.05 {
            previousDistance = newDistance
            self.distanceLabel.text = String(format: "%0.2fkm", newDistance)
            self.distanceContainer.bounce(0.1)
        }
        
        if freeBikes != previousBikes {
            previousBikes = freeBikes
            self.bikesImageView.tintColor = UIColor.colorForValue(freeBikes, min: 0, max: freeBikes + freeSlots)
            self.bikesLabel.text = "\(freeBikes)/\(freeBikes + freeSlots)"
            self.bikesImageView.bounce(0.1)
        }
        
        self.labelThird.text = "UPDATED \(date.updatedWhileAgoTextualRepresentation())".uppercaseString
    }
}