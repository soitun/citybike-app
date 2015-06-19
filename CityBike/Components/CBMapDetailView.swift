//
//  CBMapDetailView.swift
//  CityBike
//
//  Created by Tomasz Szulc on 19/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

protocol CBMapDetailViewDelegate {
    func mapDetailViewDidPressClose(view: CBMapDetailView)
}

class CBMapDetailView: UIView {
    
    var delegate: CBMapDetailViewDelegate?
    
    @IBOutlet weak var labelTop: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var labelThird: UILabel!
    
    @IBOutlet private weak var bikesImageView: UIImageView!
    @IBOutlet private weak var bikesLabel: UILabel!

    @IBOutlet private weak var slotsImageView: UIImageView!
    @IBOutlet private weak var slotsLabel: UILabel!

    @IBOutlet private weak var distanceContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private var dateFormatter: NSDateFormatter!
    
    
    @IBAction func closePressed(sender: AnyObject) {
        self.delegate?.mapDetailViewDidPressClose(self)
    }
    
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        return super.CustomAwakeAfterUsingCoder(aDecoder, nibName: "CBMapDetailView")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.distanceContainer.makeRounded()
        self.distanceContainer.backgroundColor = UIColor.plentyColor()
        self.distanceContainer.layer.cornerRadius = (CGRectGetHeight(self.distanceContainer.frame) / CGFloat(2.0))
        
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
    }
    
    func update(text: String, detailText: String, freeBikes: Int, freeSlots: Int, distance: Float, date: NSDate) {
       
        self.labelTop.text = text.uppercaseString
        self.labelDetails.text = detailText.uppercaseString
        self.bikesLabel.text = "\(freeBikes)"
        self.slotsLabel.text = "\(freeSlots)"
        self.distanceLabel.text = String(format: "%0.2fkm", arguments: [distance / 1000.0])
        
        func colorForValue(value: Int, min: Int, max: Int) -> UIColor {
            if value > max { return UIColor.plentyColor() }
            else if value == 0 { return UIColor.noneColor() }
            else { return UIColor.fewColor() }
        }
        
        self.bikesImageView.tintColor = colorForValue(freeBikes, 0, 5)
        self.slotsImageView.tintColor = colorForValue(freeSlots, 0, 5)
        
        self.labelThird.text = "UPDATED \(self.dateFormatter.stringFromDate(date))".uppercaseString
        
        // bounce
        self.bikesImageView.bounce(0.1)
        self.slotsImageView.bounce(0.1)
        self.distanceContainer.bounce(0.1)
    }
}